using System;
using System.Collections.Generic;
using System.Text;
using ChaloJi.Modules.Auth.Models;
using Microsoft.EntityFrameworkCore;

namespace ChaloJi.Modules.Auth.Data
{
    public class AuthDbContext : DbContext
    {
        public AuthDbContext(DbContextOptions<AuthDbContext> options) : base(options)
        {
        }
        public DbSet<User> Users { get; set; }
        public DbSet<DriverProfile> DriverProfiles { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            modelBuilder.Entity<DriverProfile>()
                .HasOne(dp => dp.User)
                .WithOne(u => u.DriverProfile)
                .HasForeignKey<DriverProfile>(dp => dp.UserId)
                .OnDelete(DeleteBehavior.Cascade);
        }
    }
}
