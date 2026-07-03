package com.barbershop.barber_booking_system.controllers;

import com.barbershop.barber_booking_system.dto.AppointmentDTO;
import com.barbershop.barber_booking_system.dto.BlockedSlotsDTO;
import com.barbershop.barber_booking_system.dto.CreateAppointmentDTO;
import com.barbershop.barber_booking_system.services.AppointmentService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/appointments")
@CrossOrigin(origins = "*")
public class AppointmentController {

    private final AppointmentService service;

    public AppointmentController(AppointmentService service) {
        this.service = service;
    }

    @GetMapping
    public ResponseEntity<List<AppointmentDTO>> getAll() {
        return ResponseEntity.ok(service.getAll());
    }

    @GetMapping("/blocked-slots")
    public ResponseEntity<BlockedSlotsDTO> getBlockedSlots(
            @RequestParam String date,
            @RequestParam Long barberId
    ) {
        return ResponseEntity.ok(
                service.getBlockedSlots(LocalDate.parse(date), barberId)
        );
    }

    @PostMapping
    public ResponseEntity<AppointmentDTO> create(@RequestBody CreateAppointmentDTO dto) {
        return new ResponseEntity<>(service.create(dto), HttpStatus.CREATED);
    }

    @GetMapping("/{id}")
    public ResponseEntity<AppointmentDTO> getById(@PathVariable Long id) {
        return ResponseEntity.ok(service.getById(id));
    }

    @PatchMapping("/{id}/confirm")
    public ResponseEntity<Void> confirm(@PathVariable Long id) {
        service.confirm(id);
        return ResponseEntity.ok().build();
    }

    @PatchMapping("/{id}/cancel")
    public ResponseEntity<Void> cancel(@PathVariable Long id) {
        service.cancel(id);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/{id}")
    public ResponseEntity<AppointmentDTO> update(@PathVariable Long id, @RequestBody CreateAppointmentDTO dto) {
        return ResponseEntity.ok(service.update(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/tickets")
    public ResponseEntity<List<AppointmentDTO>> getValidTickets(@RequestParam String clientName) {
        return ResponseEntity.ok(service.getValidTickets(clientName));
    }


}
