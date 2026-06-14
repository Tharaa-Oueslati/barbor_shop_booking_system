package com.barbershop.barber_booking_system.dto;

public record BarberDTO(
        Long id,
        String name,
        String phone,
        boolean active
) {}