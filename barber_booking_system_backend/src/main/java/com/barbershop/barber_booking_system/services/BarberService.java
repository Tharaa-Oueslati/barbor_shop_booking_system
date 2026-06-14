package com.barbershop.barber_booking_system.services;


import com.barbershop.barber_booking_system.dto.BarberDTO;
import com.barbershop.barber_booking_system.dto.CreateBarberDTO;
import com.barbershop.barber_booking_system.entities.Barber;
import com.barbershop.barber_booking_system.repositories.BarberRepository;

import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class BarberService {

    private final BarberRepository repository;

    public BarberService(BarberRepository repository) {
        this.repository = repository;
    }

    public List<BarberDTO> getAll() {
        return repository.findAll()
                .stream()
                .map(b -> new BarberDTO(b.getId(), b.getName(), b.getPhone(), b.isActive()))
                .toList();
    }

    public BarberDTO getById(Long id) {
        Barber b = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Barber not found"));

        return new BarberDTO(b.getId(), b.getName(), b.getPhone(), b.isActive());
    }

    public BarberDTO create(CreateBarberDTO dto) {
        Barber b = new Barber();
        b.setName(dto.name());
        b.setPhone(dto.phone());
        b.setActive(true);

        Barber saved = repository.save(b);

        return new BarberDTO(saved.getId(), saved.getName(), saved.getPhone(), saved.isActive());
    }

    public BarberDTO update(Long id, CreateBarberDTO dto) {
        Barber b = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Barber not found"));

        b.setName(dto.name());
        b.setPhone(dto.phone());

        Barber saved = repository.save(b);

        return new BarberDTO(saved.getId(), saved.getName(), saved.getPhone(), saved.isActive());
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
}