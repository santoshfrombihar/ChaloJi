using System;

namespace ChaloJi.Modules.Auth.Models.DTO
{
    /// <summary>
    /// Standard API response wrapper for consistent response format
    /// </summary>
    public class ApiResponse<T>
    {
        public bool Success { get; set; }
        public string? Message { get; set; }
        public T? Data { get; set; }
        public string? ErrorCode { get; set; }
        public DateTime Timestamp { get; set; }

        public ApiResponse()
        {
            Timestamp = DateTime.UtcNow;
        }

        public static ApiResponse<T> SuccessResponse(T data, string message = "Operation successful")
        {
            return new ApiResponse<T>
            {
                Success = true,
                Message = message,
                Data = data,
                ErrorCode = null
            };
        }

        public static ApiResponse<T> ErrorResponse(string message, string errorCode = "INTERNAL_ERROR", T? data = default)
        {
            return new ApiResponse<T>
            {
                Success = false,
                Message = message,
                Data = data,
                ErrorCode = errorCode
            };
        }
    }
}