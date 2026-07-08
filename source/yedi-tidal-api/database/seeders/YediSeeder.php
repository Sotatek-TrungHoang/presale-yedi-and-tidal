<?php

namespace Database\Seeders;

use App\Handlers\Uploads\UploadFileHandler;
use App\Models\Declaration;
use App\Models\RequiredEvidence;
use App\Models\Settings;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Http\UploadedFile;

class YediSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $this->settings();
        $this->declarations();
        $this->requiredEvidence();
    }

    protected function settings()
    {
        if (Settings::query()->exists()) {
            return;
        }

        Settings::query()->create([
            'references_required' => 2,
            'require_teacher_number' => true,
        ]);
    }

    protected function declarations()
    {
        if (Declaration::query()->exists()) {
            return;
        }

        /** @var UploadFileHandler $uploadFileHandler */
        $uploadFileHandler = app()->make(UploadFileHandler::class);
        $file = UploadedFile::fake()->createWithContent('seeded-file.txt', 'This is test data, please replace');

        $safeguardingUpload = $uploadFileHandler->handle($file);
        $declaration = Declaration::query()->create([
            'title' => 'Safeguarding Declaration',
            'description' => <<<'EOT'
                Lorem ipsum dolor sit amet consectetur adipisicing elit. Voluptatem modi libero fugit iusto est quam consequatur necessitatibus mollitia! Quia nam ullam iste cum, mollitia iure cumque beatae cupiditate reiciendis recusandae?

                Lorem ipsum dolor sit amet consectetur adipisicing elit. Voluptatem modi libero fugit iusto est quam consequatur necessitatibus mollitia! Quia nam ullam iste cum, mollitia iure cumque beatae cupiditate reiciendis recusandae?

                Lorem ipsum dolor sit amet consectetur adipisicing elit. Voluptatem modi libero fugit iusto est quam consequatur necessitatibus mollitia! Quia nam ullam iste cum, mollitia iure cumque beatae cupiditate reiciendis recusandae?
            EOT,
            'time_to_complete' => '5 mins',
            'required' => true,
        ]);
        $declaration->upload()->associate($safeguardingUpload)->save();
        $safeguardingUpload->owner()->associate($declaration)->save();

        $disqualificationUpload = $uploadFileHandler->handle($file);
        $declaration = Declaration::query()->create([
            'title' => 'Disqualification Declaration',
            'description' => <<<'EOT'
                Lorem ipsum dolor sit amet consectetur adipisicing elit. Voluptatem modi libero fugit iusto est quam consequatur necessitatibus mollitia! Quia nam ullam iste cum, mollitia iure cumque beatae cupiditate reiciendis recusandae?

                Lorem ipsum dolor sit amet consectetur adipisicing elit. Voluptatem modi libero fugit iusto est quam consequatur necessitatibus mollitia! Quia nam ullam iste cum, mollitia iure cumque beatae cupiditate reiciendis recusandae?

                Lorem ipsum dolor sit amet consectetur adipisicing elit. Voluptatem modi libero fugit iusto est quam consequatur necessitatibus mollitia! Quia nam ullam iste cum, mollitia iure cumque beatae cupiditate reiciendis recusandae?
            EOT,
            'time_to_complete' => '5 mins',
            'required' => true,
        ]);
        $declaration->upload()->associate($disqualificationUpload)->save();
        $disqualificationUpload->owner()->associate($declaration)->save();

        $medicalUpload = $uploadFileHandler->handle($file);
        $declaration = Declaration::query()->create([
            'title' => 'Medical Declaration',
            'description' => <<<'EOT'
                Lorem ipsum dolor sit amet consectetur adipisicing elit. Voluptatem modi libero fugit iusto est quam consequatur necessitatibus mollitia! Quia nam ullam iste cum, mollitia iure cumque beatae cupiditate reiciendis recusandae?

                Lorem ipsum dolor sit amet consectetur adipisicing elit. Voluptatem modi libero fugit iusto est quam consequatur necessitatibus mollitia! Quia nam ullam iste cum, mollitia iure cumque beatae cupiditate reiciendis recusandae?

                Lorem ipsum dolor sit amet consectetur adipisicing elit. Voluptatem modi libero fugit iusto est quam consequatur necessitatibus mollitia! Quia nam ullam iste cum, mollitia iure cumque beatae cupiditate reiciendis recusandae?
            EOT,
            'time_to_complete' => '5 mins',
            'required' => true,
        ]);
        $declaration->upload()->associate($medicalUpload)->save();
        $medicalUpload->owner()->associate($declaration)->save();
    }

    protected function requiredEvidence()
    {
        if (RequiredEvidence::query()->exists()) {
            return;
        }

        RequiredEvidence::query()->create([
            'title' => 'DBS Evidence',
            'time_to_complete' => '3-5 mins',
            'required' => true,
        ]);
    }
}
