package com.barbershop.barber_booking_system.services;

import com.barbershop.barber_booking_system.dto.AppointmentDTO;
import com.barbershop.barber_booking_system.dto.CreateAppointmentDTO;
import com.barbershop.barber_booking_system.entities.Appointment;
import com.barbershop.barber_booking_system.entities.AppointmentStatus;
import com.barbershop.barber_booking_system.entities.Barber;
import com.barbershop.barber_booking_system.entities.HaircutType;
import com.barbershop.barber_booking_system.repositories.AppointmentRepository;
import com.barbershop.barber_booking_system.repositories.BarberRepository;
import com.barbershop.barber_booking_system.repositories.HaircutTypeRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@Service
public class AppointmentService {

    private final AppointmentRepository repository;
    private final BarberRepository barberRepository;
    private final HaircutTypeRepository haircutTypeRepository;

    public AppointmentService(AppointmentRepository repository, BarberRepository barberRepository, HaircutTypeRepository haircutTypeRepository) {
        this.repository = repository;
        this.barberRepository = barberRepository;
        this.haircutTypeRepository = haircutTypeRepository;
    }

    public List<AppointmentDTO> getAll() {
        return repository.findAll()
                .stream()
                .map(this::toDTO)
                .toList();
    }

    public AppointmentDTO getById(Long id) {
        Appointment appointment = repository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Appointment not found with id: " + id));
        return toDTO(appointment);
    }

    public AppointmentDTO create(CreateAppointmentDTO dto) {
        Barber barber = barberRepository.findById(dto.barberId())
                .orElseThrow(() -> new EntityNotFoundException("Barber not found with id: " + dto.barberId()));

        HaircutType haircutType = haircutTypeRepository.findById(dto.haircutTypeId())
                .orElseThrow(() -> new EntityNotFoundException("Haircut type not found with id: " + dto.haircutTypeId()));

        LocalDate date = LocalDate.parse(dto.date());
        LocalTime startTime = LocalTime.parse(dto.startTime());
        LocalTime endTime = startTime.plusMinutes(haircutType.getDuration());

        if (repository.existsByBarberIdAndDateAndStartTime(barber.getId(), date, startTime)) {
            throw new IllegalStateException("Barber is already booked for this time slot");
        }

        Appointment appointment = Appointment.builder()
                .clientName(dto.clientName())
                .clientPhone(dto.clientPhone())
                .clientEmail(dto.clientEmail())
                .barber(barber)
                .haircutType(haircutType)
                .date(date)
                .startTime(startTime)
                .endTime(endTime)
                .status(AppointmentStatus.PENDING)
                .build();

        Appointment saved = repository.save(appointment);
        return toDTO(saved);
    }

    public AppointmentDTO update(Long id, CreateAppointmentDTO dto) {
        Appointment existing = repository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Appointment not found with id: " + id));

        Barber barber = barberRepository.findById(dto.barberId())
                .orElseThrow(() -> new EntityNotFoundException("Barber not found with id: " + dto.barberId()));

        HaircutType haircutType = haircutTypeRepository.findById(dto.haircutTypeId())
                .orElseThrow(() -> new EntityNotFoundException("Haircut type not found with id: " + dto.haircutTypeId()));

        LocalDate date = LocalDate.parse(dto.date());
        LocalTime startTime = LocalTime.parse(dto.startTime());
        LocalTime endTime = startTime.plusMinutes(haircutType.getDuration());

        if (!existing.getBarber().getId().equals(barber.getId()) ||
            !existing.getDate().equals(date) ||
            !existing.getStartTime().equals(startTime)) {
            if (repository.existsByBarberIdAndDateAndStartTime(barber.getId(), date, startTime)) {
                throw new IllegalStateException("Barber is already booked for this time slot");
            }
        }

        existing.setClientName(dto.clientName());
        existing.setClientPhone(dto.clientPhone());
        existing.setClientEmail(dto.clientEmail());
        existing.setBarber(barber);
        existing.setHaircutType(haircutType);
        existing.setDate(date);
        existing.setStartTime(startTime);
        existing.setEndTime(endTime);

        Appointment saved = repository.save(existing);
        return toDTO(saved);
    }

    public void delete(Long id) {
        if (!repository.existsById(id)) {
            throw new EntityNotFoundException("Appointment not found with id: " + id);
        }
        repository.deleteById(id);
    }

    private AppointmentDTO toDTO(Appointment a) {
        return new AppointmentDTO(
                a.getId(),
                a.getClientName(),
                a.getClientPhone(),
                a.getClientEmail(),
                a.getBarber().getId(),
                a.getHaircutType().getId(),
                a.getDate().toString(),
                a.getStartTime().toString(),
                a.getStatus().name()
        );
    }
}
