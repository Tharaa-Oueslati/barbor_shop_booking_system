package com.barbershop.barber_booking_system.dto;

public record CreateHaircutTypeDTO(
        String name,
        double price,
        int duration
) {}
