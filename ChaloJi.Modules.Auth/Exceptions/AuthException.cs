using System;

namespace ChaloJi.Modules.Auth.Exceptions
{
    /// <summary>
    /// Custom exception for authentication-related errors
    /// </summary>
    public class AuthException : Exception
    {
        public string ErrorCode { get; set; }

        public AuthException(string message, string errorCode = "AUTH_ERROR") : base(message)
        {
            ErrorCode = errorCode;
        }
    }
}