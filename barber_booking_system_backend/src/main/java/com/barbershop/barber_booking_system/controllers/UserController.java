package com.barbershop.barber_booking_system.controllers;


import com.barbershop.barber_booking_system.dto.UserDTO;

import org.springframework.web.bind.annotation.*;

import java.util.List;
@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping
    public List<UserDTO> getAllUsers() {
        return userService.getAll();
    }

    @PostMapping
    public UserDTO create(@RequestBody CreateUserDTO dto) {
        return userService.create(dto);
    }

    @GetMapping("/{id}")
    public UserDTO getById(@PathVariable Long id) {
        return userService.getById(id);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        userService.delete(id);
    }
}