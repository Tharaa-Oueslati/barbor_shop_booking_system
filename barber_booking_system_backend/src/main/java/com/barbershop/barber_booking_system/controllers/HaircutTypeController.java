package com.barbershop.barber_booking_system.controllers;

@RestController
@RequestMapping("/api/haircut-types")
public class HaircutTypeController {

    private final HaircutTypeService service;

    public HaircutTypeController(HaircutTypeService service) {
        this.service = service;
    }

    @GetMapping
    public List<HaircutTypeDTO> getAll() {
        return service.getAll();
    }

    @PostMapping
    public HaircutTypeDTO create(@RequestBody CreateHaircutTypeDTO dto) {
        return service.create(dto);
    }

    @GetMapping("/{id}")
    public HaircutTypeDTO getById(@PathVariable Long id) {
        return service.getById(id);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        service.delete(id);
    }
}
