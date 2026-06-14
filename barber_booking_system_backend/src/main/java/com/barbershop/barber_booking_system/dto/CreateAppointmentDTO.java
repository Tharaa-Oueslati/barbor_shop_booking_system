package com.barbershop.barber_booking_system.dto;

public record CreateAppointmentDTO(
        String clientName,
        String clientPhone,
        String clientEmail,
        Long barberId,
        Long haircutTypeId,
        String date,
        String startTime
) {}
