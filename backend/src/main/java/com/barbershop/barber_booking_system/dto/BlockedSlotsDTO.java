package com.barbershop.barber_booking_system.dto;

import java.util.List;

public record BlockedSlotsDTO(
        List<String> blockedTimes
) {}