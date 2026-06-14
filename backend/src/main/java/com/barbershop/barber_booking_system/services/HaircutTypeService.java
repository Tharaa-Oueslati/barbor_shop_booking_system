package com.barbershop.barber_booking_system.services;

import com.barbershop.barber_booking_system.dto.CreateHaircutTypeDTO;
import com.barbershop.barber_booking_system.dto.HaircutTypeDTO;
import com.barbershop.barber_booking_system.entities.HaircutType;
import com.barbershop.barber_booking_system.repositories.HaircutTypeRepository;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;

@Service
public class HaircutTypeService {

    private final HaircutTypeRepository repository;

    public HaircutTypeService(HaircutTypeRepository repository) {
        this.repository = repository;
    }

    public List<HaircutTypeDTO> getAll() {
        return repository.findAll()
                .stream()
                .map(h -> new HaircutTypeDTO(h.getId(), h.getName(), h.getPrice().doubleValue(), h.getDuration()))
                .toList();
    }

    public HaircutTypeDTO getById(Long id) {
        HaircutType h = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Haircut type not found"));

        return new HaircutTypeDTO(h.getId(), h.getName(), h.getPrice().doubleValue(), h.getDuration());
    }

    public HaircutTypeDTO create(CreateHaircutTypeDTO dto) {
        HaircutType h = new HaircutType();
        h.setName(dto.name());
        h.setPrice(BigDecimal.valueOf(dto.price()));
        h.setDuration(dto.duration());

        HaircutType saved = repository.save(h);

        return new HaircutTypeDTO(saved.getId(), saved.getName(), saved.getPrice().doubleValue(), saved.getDuration());
    }

    public HaircutTypeDTO update(Long id, CreateHaircutTypeDTO dto) {
        HaircutType h = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Haircut type not found"));

        h.setName(dto.name());
        h.setPrice(BigDecimal.valueOf(dto.price()));
        h.setDuration(dto.duration());

        HaircutType saved = repository.save(h);

        return new HaircutTypeDTO(saved.getId(), saved.getName(), saved.getPrice().doubleValue(), saved.getDuration());
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }
}
