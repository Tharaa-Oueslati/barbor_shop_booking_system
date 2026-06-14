package com.barbershop.barber_booking_system.repositories;

import com.barbershop.barber_booking_system.entities.Appointment;
import com.barbershop.barber_booking_system.entities.AppointmentStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;

public interface AppointmentRepository extends JpaRepository<Appointment, Long> {

    // Check if a barber is already booked for a given slot
    boolean existsByBarberIdAndDateAndStartTime(
            Long barberId,
            LocalDate date,
            java.time.LocalTime startTime
    );
    @Modifying
    @Query("UPDATE Appointment a SET a.status = :status WHERE a.id = :id")
    void updateStatus(@Param("id") Long id,
                     @Param("status") AppointmentStatus status);
    default void confirmAppointment(Long id) {
        updateStatus(id, AppointmentStatus.CONFIRMED);
    }

    default void cancelAppointment(Long id) {
         updateStatus(id, AppointmentStatus.CANCELLED);
    }





    // Barber dashboard
    List<Appointment> findByBarberId(Long barberId);

    // Barber schedule for a specific day
    List<Appointment> findByBarberIdAndDate(Long barberId, LocalDate date);

    // Admin filters
    List<Appointment> findByStatus(AppointmentStatus status);

    List<Appointment> findByDate(LocalDate date);

    List<Appointment> findByBarberIdAndStatus(Long barberId, AppointmentStatus status);

}
