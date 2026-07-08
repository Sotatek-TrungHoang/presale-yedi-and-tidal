<?php

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
        Schema::table('settings', function (Blueprint $table) {
            $table->after('default_advertiser_charge_percentage', function (Blueprint $table) {
                $table->integer('invoice_due_date_days')->default(7);
                $table->float('invoice_late_payment_charge_percent')->default(20);
                $table->string('invoice_payment_account_name')->nullable();
                $table->string('invoice_payment_account_number')->nullable();
                $table->string('invoice_payment_account_sort_code')->nullable();
                $table->string('invoice_contact_address')->nullable();
                $table->string('invoice_contact_email')->nullable();
                $table->string('invoice_contact_telephone')->nullable();
            });
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('settings', function (Blueprint $table) {
            $table->dropColumn([
                'invoice_due_date_days',
                'invoice_late_payment_charge_percent',
                'invoice_payment_account_name',
                'invoice_payment_account_number',
                'invoice_payment_account_sort_code',
                'invoice_contact_address',
                'invoice_contact_email',
                'invoice_contact_telephone',
            ]);
        });
    }
};
