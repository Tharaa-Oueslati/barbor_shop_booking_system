package com.barbershop.barber_booking_system.dto;

import java.util.List;

public record BlockedSlotsDTO(
        List<BookedSlotDTO> bookedSlots
) {
    public record BookedSlotDTO(
            String startTime,
            int duration
    ) {}
}
