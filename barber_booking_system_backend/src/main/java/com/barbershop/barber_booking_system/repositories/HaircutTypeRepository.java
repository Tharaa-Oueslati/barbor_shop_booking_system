package com.barbershop.barber_booking_system.repositories;

import com.barbershop.barber_booking_system.entities.HaircutType;
import org.springframework.data.jpa.repository.JpaRepository;

public interface HaircutTypeRepository extends JpaRepository<HaircutType, Long> {

}
