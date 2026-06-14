package com.barbershop.barber_booking_system.dto;

public record HaircutTypeDTO(
        Long id,
        String name,
        double price,
        int duration
) {}