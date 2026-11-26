<?php

namespace App\Http\Requests;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Http\Exceptions\HttpResponseException;

class GunMilanRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'boy' => ['required', 'array'],
            'boy.date' => ['required', 'string', 'regex:/^\d{1,2}[-\/.]\d{1,2}[-\/.]\d{4}$/'],
            'boy.time' => ['required', 'string', 'regex:/^\d{1,2}:\d{2}(:\d{2})?$/'],
            'boy.lat' => ['required', 'numeric', 'not_in:0'],
            'boy.lng' => ['required', 'numeric', 'not_in:0'],
            'boy.name' => ['nullable', 'string', 'max:255'],
            'boy.place' => ['nullable', 'string', 'max:255'],
            'boy.state' => ['nullable', 'string', 'max:255'],
            'boy.district' => ['nullable', 'string', 'max:255'],
            'boy.tz_offset' => ['nullable', 'string', 'max:10'],

            'girl' => ['required', 'array'],
            'girl.date' => ['required', 'string', 'regex:/^\d{1,2}[-\/.]\d{1,2}[-\/.]\d{4}$/'],
            'girl.time' => ['required', 'string', 'regex:/^\d{1,2}:\d{2}(:\d{2})?$/'],
            'girl.lat' => ['required', 'numeric', 'not_in:0'],
            'girl.lng' => ['required', 'numeric', 'not_in:0'],
            'girl.name' => ['nullable', 'string', 'max:255'],
            'girl.place' => ['nullable', 'string', 'max:255'],
            'girl.state' => ['nullable', 'string', 'max:255'],
            'girl.district' => ['nullable', 'string', 'max:255'],
            'girl.tz_offset' => ['nullable', 'string', 'max:10'],

            'ayanamsha' => ['nullable', 'string', 'in:lahiri,kp,Lahiri,KP,LAHIRI'],
            'engine' => ['nullable', 'string', 'max:50'],
        ];
    }

    public function messages(): array
    {
        return [
            'boy.required' => __('validation.gunmilan_boy_required'),
            'girl.required' => __('validation.gunmilan_girl_required'),
            'boy.date.required' => __('validation.gunmilan_boy_date_required'),
            'boy.time.required' => __('validation.gunmilan_boy_time_required'),
            'boy.lat.required' => __('validation.gunmilan_boy_lat_required'),
            'boy.lng.required' => __('validation.gunmilan_boy_lng_required'),
            'girl.date.required' => __('validation.gunmilan_girl_date_required'),
            'girl.time.required' => __('validation.gunmilan_girl_time_required'),
            'girl.lat.required' => __('validation.gunmilan_girl_lat_required'),
            'girl.lng.required' => __('validation.gunmilan_girl_lng_required'),
            'boy.date.regex' => __('validation.gunmilan_boy_date_regex'),
            'girl.date.regex' => __('validation.gunmilan_girl_date_regex'),
        ];
    }

    protected function failedValidation(Validator $validator): void
    {
        throw new HttpResponseException(response()->json([
            'success' => false,
            'error' => $validator->errors()->first(),
            'errors' => $validator->errors(),
        ], 400));
    }
}
