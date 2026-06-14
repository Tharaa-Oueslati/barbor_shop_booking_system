package com.barbershop.barber_booking_system.repositories;

import com.barbershop.barber_booking_system.entities.Appointment;
import com.barbershop.barber_booking_system.entities.AppointmentStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;

public interface AppointmentRepository extends JpaRepository<Appointment, Long> {

    // Check if a barber is already booked for a given slot
    boolean existsByBarberIdAndDateAndStartTime(
            Long barberId,
            LocalDate date,
            java.time.LocalTime startTime
    );

    // Barber dashboard
    List<Appointment> findByBarberId(Long barberId);

    // Barber schedule for a specific day
    List<Appointment> findByBarberIdAndDate(Long barberId, LocalDate date);

    // Admin filters
    List<Appointment> findByStatus(AppointmentStatus status);

    List<Appointment> findByDate(LocalDate date);

    List<Appointment> findByBarberIdAndStatus(Long barberId, AppointmentStatus status);

}
