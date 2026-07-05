package com.barbershop.barber_booking_system.dto;

public record CreateUserDTO(
        String username,
        String password,
        String email,
        String role
) {

}