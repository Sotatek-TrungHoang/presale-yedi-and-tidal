<?php

namespace App\Console\Commands\Common;

use App\Models\Upload;
use Illuminate\Console\Command;

class ClearExpiredUploadsCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'common:uploads:clear-expired';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Clear unowned uploads';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $query = Upload::query()
            ->where('expires_at', '<', now())
            ->whereDoesntHave('owner')
            ->cursor();
        foreach ($query as $upload) {
            $upload->forceDelete();
        }
    }
}
