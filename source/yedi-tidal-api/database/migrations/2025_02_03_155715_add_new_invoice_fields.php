<?php

use App\Models\Invoice;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('invoices', function (Blueprint $table) {
            $table->after('upload_id', function (Blueprint $table) {
                $table->datetime('due_date')->default(now()->addDays(7));
                $table->integer('invoice_due_date_days')->default(7);
                $table->float('invoice_late_payment_charge_percent');
                $table->json('sub_total');
                $table->json('vat');
                $table->json('total');
            });
        });

        Schema::create('invoice_items', function (Blueprint $table) {
            $table->id();
            $table->foreignIdFor(Invoice::class)->constrained()->cascadeOnDelete();
            $table->date('date');
            $table->string('description');
            $table->string('rate_type');
            $table->json('rate');
            $table->json('quantity');
            $table->json('amount');
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('invoice_items');
        Schema::table('invoices', function (Blueprint $table) {
            $table->dropColumn([
                'due_date',
                'invoice_due_date_days',
                'invoice_late_payment_charge_percent',
                'sub_total',
                'vat',
                'total',
            ]);
        });
    }
};
