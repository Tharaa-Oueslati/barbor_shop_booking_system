package com.barbershop.barber_booking_system.dto;

public record AppointmentDTO(
        Long id,
        String clientName,
        String clientPhone,
        String clientEmail,
        Long barberId,
        Long haircutTypeId,
        String date,
        String startTime,
        String status
) {}