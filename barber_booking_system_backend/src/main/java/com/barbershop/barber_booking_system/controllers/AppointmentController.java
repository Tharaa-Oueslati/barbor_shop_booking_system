package com.barbershop.barber_booking_system.controllers;

@RestController
@RequestMapping("/api/appointments")
public class AppointmentController {

    private final AppointmentService service;

    public AppointmentController(AppointmentService service) {
        this.service = service;
    }

    @GetMapping
    public List<AppointmentDTO> getAll() {
        return service.getAll();
    }

    @PostMapping
    public AppointmentDTO create(@RequestBody CreateAppointmentDTO dto) {
        return service.create(dto);
    }

    @GetMapping("/{id}")
    public AppointmentDTO getById(@PathVariable Long id) {
        return service.getById(id);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        service.delete(id);
    }
}
