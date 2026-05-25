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
        public DbSet<AadhaarKyc> AadhaarKycs { get; set; }
        public DbSet<PanCard> PanCards { get; set; }
        public DbSet<VehicleDetail> VehicleDetails { get; set; }
        public DbSet<DriverLicense> DriverLicenses { get; set; }
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            modelBuilder.Entity<DriverProfile>()
                .HasOne(dp => dp.User)
                .WithOne(u => u.DriverProfile)
                .HasForeignKey<DriverProfile>(dp => dp.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            // 1. Enforce Unique Constraint on Aadhaar Number
            modelBuilder.Entity<AadhaarKyc>()
                .HasIndex(a => a.AadhaarNumber)
                .IsUnique();

            // 2. Enforce Unique Constraint on PAN Number
            modelBuilder.Entity<PanCard>()
                .HasIndex(p => p.PanNumber)
                .IsUnique();

            // 3. Enforce Unique Constraint on Vehicle Number (Bonus: No two drivers can register same vehicle)
            modelBuilder.Entity<VehicleDetail>()
                .HasIndex(v => v.VehicleNumber)
                .IsUnique();

            // 4. Enforce Unique Constraint on License Number
            modelBuilder.Entity<DriverLicense>()
                .HasIndex(l => l.LicenseNumber)
                .IsUnique();
        }
    }
}
