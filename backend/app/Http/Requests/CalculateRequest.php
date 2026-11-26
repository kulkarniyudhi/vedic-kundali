<?php

namespace App\Http\Requests;

use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Http\Exceptions\HttpResponseException;

class CalculateRequest extends FormRequest
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
            'date' => ['required', 'string', 'regex:/^\d{1,2}[-\/.]\d{1,2}[-\/.]\d{4}$/'],
            'time' => ['required', 'string', 'regex:/^\d{1,2}:\d{2}(:\d{2})?$/'],
            'lat' => ['required', 'numeric', 'not_in:0'],
            'lng' => ['required', 'numeric', 'not_in:0'],
            'place' => ['nullable', 'string', 'max:255'],
            'state' => ['nullable', 'string', 'max:255'],
            'district' => ['nullable', 'string', 'max:255'],
            'tz_offset' => ['nullable', 'string', 'max:10'],
            'ayanamsha' => ['nullable', 'string', 'in:lahiri,kp,Lahiri,KP,LAHIRI'],
            'engine' => ['nullable', 'string', 'max:50'],
        ];
    }

    public function messages(): array
    {
        return [
            'date.required' => __('validation.kundali_date_required'),
            'time.required' => __('validation.kundali_time_required'),
            'lat.required' => __('validation.kundali_lat_required'),
            'lng.required' => __('validation.kundali_lng_required'),
            'lat.not_in' => __('validation.kundali_lat_not_in'),
            'lng.not_in' => __('validation.kundali_lng_not_in'),
            'date.regex' => __('validation.kundali_date_regex'),
            'time.regex' => __('validation.kundali_time_regex'),
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
