using System;
using System.Collections.Generic;
using System.Text;
using ChaloJi.Modules.Auth.Models.DTO;

namespace ChaloJi.Modules.Auth.Services.Interface
{
    public interface IAuthService
    {
        Task<RegisterDto> RegisterUser(RegisterDto registerDto);
        Task<LoginResponseDto> LoginUser(LoginDto loginDto);
    }
}
