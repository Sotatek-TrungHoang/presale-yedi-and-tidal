<?php

namespace App\Console\Commands\Contracts;

use App\Jobs\CreateApplicantContractJob;
use App\Models\Applicant;
use Illuminate\Console\Command;

class GenerateApplicantContractsCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'contracts:generate-applicant';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Generate contracts for applicants';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        Applicant::query()
            ->cursor()
            ->each(fn (Applicant $applicant) => CreateApplicantContractJob::dispatchSync($applicant));
    }
}
