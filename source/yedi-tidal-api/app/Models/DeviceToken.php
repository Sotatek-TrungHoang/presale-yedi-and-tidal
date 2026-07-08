<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DeviceToken extends Model
{
    protected $fillable = [
        'user_id',
        'device_token',
        'last_used',
    ];

    protected $casts = [
        'last_used' => 'datetime',
    ];

    /** @return BelongsTo<User, DeviceToken>  */
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
