# Code Standards & Conventions

**Last updated:** 2026-07-08  
**Applies to:** All PHP, Blade, JavaScript in yedi-tidal-api

This document captures actual conventions observed in the codebase, not prescriptive rules. Follow these when contributing.

## PHP Code Structure

### Layering: Controller → Handler → Model

**Controllers** (`app/Http/Controllers/`)
- Thin; delegate business logic to Handlers
- Call Gates for authorization
- Validate input via Request classes (not inline)
- Return JSON via `stdResponse()`, `stdSuccess()`, `stdError()` helpers
- Group by audience: Advertiser/, Applicant/, Common/, Public/

Example:
```php
public function store(CreateAdvertRequest $request)
{
    $handler = new CreateAdvertHandler();
    $advert = $handler->handle($request->toData());
    return $this->stdSuccess(new AdvertResource($advert));
}
```

**Handlers** (`app/Handlers/`)
- Single responsibility per class
- Constructor-injected dependencies (composition)
- Business logic lives here, not in models
- Transactional when modifying multiple entities
- Notify via handler composition (`NotifyAdminsHandler`, etc.)

Example:
```php
class CreateAdvertHandler
{
    public function __construct(
        private SettingsResolver $settings,
        private NotifyAdminsHandler $notifyAdmins
    ) {}

    public function handle(CreateAdvertData $data): Advert
    {
        $advert = Advert::create([...]);
        // Create related shifts
        // Apply defaults
        $this->notifyAdmins->handle(...);
        return $advert;
    }
}
```

**Models** (`app/Models/`)
- Eloquent relations and casts
- Boot hooks for lifecycle events (geocoding, image conversion dispatch)
- Computed attributes for derived data
- **No business logic** — delegate to Handlers

Example:
```php
class Advert extends Model
{
    protected function advertisePay(): Attribute
    {
        return Attribute::make(
            get: fn () => $this->advertiser_pay_rate->minus(
                Money::of($this->advertiserCharge(), GBP::class)
            ),
        )->shouldCache();
    }
}
```

### Naming Conventions

| Construct | Convention | Example |
|-----------|-----------|---------|
| Classes | PascalCase | `CreateAdvertHandler`, `AdvertPolicy` |
| Methods | camelCase | `handle()`, `createAdvert()` |
| Properties | snake_case | `$advertiser_pay_rate`, `$applied_at` |
| Constants | SCREAMING_SNAKE_CASE | — (rare in Laravel) |
| Database columns | snake_case | `advertiser_pay_rate`, `apply_by` |
| Routes | kebab-case URLs | `/app/common`, `/app/advertiser/adverts` |
| File names (classes) | PascalCase.php | `CreateAdvertHandler.php` |
| File names (config) | kebab-case.php | `audit.php`, `horizon.php` |

### Type Declarations

Always declare parameter and return types (PHP 8.2+).

```php
public function handle(CreateAdvertData $data): Advert
```

Use `?Type` for nullable, `Type[]` for arrays, union types for multiple options.

## Eloquent Patterns

### Casts

```php
protected $casts = [
    'type' => AdvertType::class,           // String-backed enum
    'advertiser_pay_rate' => MoneyCast::class,  // Brick Money
    'starts_at' => 'datetime',             // Carbon
    'compliance_status' => AdvertiserComplianceStatus::class,
];
```

### Boot Hooks

```php
protected static function booted(): void
{
    static::creating(function ($model) {
        $model->reference_id = Str::uuid();
    });

    static::saving(function ($model) {
        if ($model->isDirty('line_1')) {
            GetAddressCoordinatesHandler::dispatch($model);
        }
    });
}
```

### Soft Deletes & Auditing

Nearly all models use both (except DeviceToken, Settings, Reference):

```php
use SoftDeletes, Auditable;

class Advert extends Model
{
    use SoftDeletes;

    public function auditable(): array
    {
        return $this->getAttributes();
    }
}
```

### Relations

```php
class Advert extends Model
{
    public function advertiser(): BelongsTo
    {
        return $this->belongsTo(Advertiser::class);
    }

    public function applications(): HasMany
    {
        return $this->hasMany(Application::class);
    }

    public function acceptedApplication(): HasOne
    {
        return $this->hasOne(Application::class)->where('status', ApplicationStatus::Accepted);
    }

    public function documents(): MorphMany
    {
        return $this->morphMany(Document::class, 'owner');
    }
}
```

## DTOs (Spatie LaravelData)

```php
class CreateAdvertData extends Data
{
    public function __construct(
        public string $title,
        public AdvertType $type,
        public CarbonInterface $starts_at,
        #[ArrayType(ShiftData::class)]
        public array $shifts,
        #[DataCollectionOf(DocumentData::class)]
        public DataCollection $documents,
    ) {}
}
```

Validate in Request → map to DTO → pass to Handler.

## Enums

All string-backed; most implement Filament traits:

```php
enum AdvertStatus: string implements HasLabel, HasColor
{
    case PendingApproval = 'pending_approval';
    case Approved = 'approved';
    case Filled = 'filled';

    public function getLabel(): string
    {
        return match ($this) {
            AdvertStatus::PendingApproval => ___('advert.status.pending_approval'),
            AdvertStatus::Approved => ___('advert.status.approved'),
            // ...
        };
    }

    public function getColor(): string|array|null
    {
        return match ($this) {
            AdvertStatus::Approved => 'success',
            AdvertStatus::Rejected => 'danger',
            // ...
        };
    }
}
```

## User-Facing Strings

**Always use `___()`, never `__()`:**

```php
// ✓ Correct
return $this->stdError(message: ___('auth.invalid_credentials'));

// ✗ Wrong
return $this->stdError(message: __('auth.invalid_credentials'));
```

The `___()` helper prefixes the key with the active brand namespace (yedi or tidal), resolving from `lang/en/yedi.php` or `lang/en/tidal.php`.

## Validation & Requests

Validation rules in Request class; authorization in `authorize()` method:

```php
class CreateAdvertRequest extends FormRequest
{
    public function authorize(): bool
    {
        return Gate::authorize('create', Advert::class);
    }

    public function rules(): array
    {
        return [
            'title' => 'required|string|max:255',
            'type' => ['required', new Enum(AdvertType::class)],
            'advertiser_pay_rate.amount' => 'required|integer|min:1',
            'address_id' => ['required', new AddressRule($this->user()->userable)],
        ];
    }

    public function toData(): CreateAdvertData
    {
        return CreateAdvertData::from($this->validated());
    }
}
```

Use custom rules for complex validation (ownership, uniqueness):

```php
class UploadRule extends Rule
{
    public function __construct(private ?Model $owner = null) {}

    public function validate($attribute, $value, $fail): void
    {
        $upload = Upload::find($value);
        if (!$upload || ($this->owner && !$upload->owner?->is($this->owner))) {
            $fail('Invalid upload.');
        }
    }
}
```

## Authorization (Policies)

```php
class AdvertPolicy
{
    public function viewAny(User $user): bool
    {
        return true; // Public listing (with compliance filters in query)
    }

    public function create(User $user): bool
    {
        return $user->isAdvertiser()
            && $user->userable->profile_status === ProfileStatus::Active
            && $user->userable->compliance_status === AdvertiserComplianceStatus::Compliant;
    }

    public function apply(User $user, Advert $advert): bool
    {
        return $user->isApplicant()
            && $user->userable->compliance_status === ApplicantComplianceStatus::Compliant
            && $advert->status === AdvertStatus::Approved
            && !$user->userable->applications()->where('advert_id', $advert->id)->exists();
    }
}
```

Use in controllers: `Gate::authorize('create', Advert::class);`

## Money Handling

All monetary amounts use Brick Money (GBP), stored as JSON:

```php
use Brick\Money\Money;
use Brick\Currency\Currency;

$rate = Money::of(25000, GBP::class);  // 25 GBP (in minor units)
$invoice->total = Money::of(80000, GBP::class);  // 80 GBP

// Cast to Brick Money via MoneyCast
class Advert extends Model
{
    protected $casts = [
        'advertiser_pay_rate' => MoneyCast::class,
    ];
}

// Computations
$total = $rate->multipliedBy(hours);
$withCharge = $rate->plus(charge);
```

JSON structure: `{amount: <minor_units>, currency: "GBP"}`

## Notifications

Organized by audience; extend `AbstractNotification`:

```php
class NewApplicationNotification extends AbstractNotification implements ShouldQueue
{
    public function via($notifiable): array
    {
        return ['mail', FcmChannel::class];
    }

    public function toMail($notifiable): MailMessage
    {
        return $this->markdown('mail.advertiser.new-application', [
            'advertiser' => $notifiable->userable,
            'applicant' => $this->application->applicant,
        ]);
    }

    public function fcm($notifiable): FcmNotificationData
    {
        return new FcmNotificationData(
            title: ___('notifications.new_application_title'),
            body: ___('notifications.new_application_body'),
            data: ['application_id' => $this->application->id],
        );
    }
}
```

Mail templates: `resources/views/mail/{advertiser,applicant,common,admin,public}/*.blade.php`

## Queue Jobs

All inherit `ShouldQueue`:

```php
class CreateAdvertInvoiceJob implements ShouldQueue
{
    public $queue = 'documents';
    public $tries = 3;
    public $timeout = 600;

    public function handle(Advert $advert): void
    {
        $invoice = Invoice::create([...]);
        // Render to PDF via DocGenConnector
        $upload = $handler->handle(...);
        $advert->invoice()->associate($upload)->save();
        // Notify
    }
}

// Dispatch: dispatch(new CreateAdvertInvoiceJob($advert));
```

## Testing

**Current state:** No tests written; directory exists but unused.

When tests are added, follow:
- Unit tests in `tests/Unit/` for Handlers, Services, Enums
- Feature tests in `tests/Feature/` for Controllers, Policies
- Use `testing` database (configured in `phpunit.xml`)
- Queue: QUEUE_CONNECTION=sync for deterministic tests
- Factories for model generation (currently only UserFactory exists)

## Code Quality Tools

**Laravel Pint** (linting):
```bash
./vendor/bin/sail php ./vendor/bin/pint
```

Runs pre-commit via Husky; Sail containers must be running to commit.

**PhpStan** (static analysis): configured but not run in CI yet (commented in Husky).

## Filament Admin Patterns

**Resources:**
```php
class AdvertResource extends Resource
{
    protected static ?string $model = Advert::class;

    public static function form(Form $form): Form
    {
        return $form->schema([
            Select::make('advertiser_id')->relationship('advertiser', 'name'),
            Textarea::make('description'),
            // ...
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table->columns([
            TextColumn::make('title'),
            TextColumn::make('status')->badge(),
            // ...
        ]);
    }
}
```

**Pages (custom):**
```php
class System extends Page
{
    protected static ?string $navigationIcon = 'heroicon-o-document-text';
    protected static string $view = 'filament.pages.settings';

    public Settings $settings;

    public function mount(): void
    {
        $this->settings = SettingsResolver::resolve();
    }
}
```

**Widgets:**
```php
class Dashboard extends ChartWidget
{
    protected int | string | array $columnSpan = 'full';
    protected static string $chartType = 'bar';

    protected function getData(): array
    {
        return [
            'datasets' => [
                [
                    'label' => ___('widgets.monthly_applications'),
                    'data' => [...],
                ],
            ],
        ];
    }
}
```

## Blade Templates

Use the `___()` helper for user-facing text:

```blade
<h1>{{ ___('adverts.title') }}</h1>
<button>{{ ___('buttons.apply') }}</button>

@if (config('app.configuration') === 'yedi')
    <img src="{{ asset('images/yedi-logo.svg') }}" />
@else
    <img src="{{ asset('images/tidal-logo.svg') }}" />
@endif
```

## Directory Organization Best Practices

- Keep classes focused on single responsibility
- Group related classes in subdirectories (e.g., `Handlers/Advertisers/Adverts/`)
- Use namespaces that reflect directory structure
- Avoid deeply nested folders (2–3 levels max)

## Version Control

**Commits:** Follow conventional commit format:
- `feat: add new feature`
- `fix: resolve issue`
- `docs: update documentation`
- `refactor: improve code structure`
- `test: add test coverage`
- `chore: dependency update`

No references to plan artifacts (phase numbers, finding codes) in commit messages.

## Security & Compliance

- **GDPR:** Support full account deletion via `DeleteAccountController`
- **Passwords:** Hash via Laravel's built-in hashing; use `Password::default()` validation
- **Signed URLs:** Use for file downloads to prevent direct path exposure
- **Polymorphic authorization:** Check both user type and owner relationship
- **SQL Injection:** Always use parameter binding (Eloquent does this by default)
- **CSRF:** Protected by middleware on web routes
- **Sanctum:** Token-based API auth; expires per config

