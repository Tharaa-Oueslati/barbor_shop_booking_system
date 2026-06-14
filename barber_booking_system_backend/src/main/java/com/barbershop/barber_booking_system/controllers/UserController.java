package com.barbershop.barber_booking_system.controllers;


import com.barbershop.barber_booking_system.dto.CreateUserDTO;
import com.barbershop.barber_booking_system.dto.UserDTO;
import com.barbershop.barber_booking_system.services.UserService;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping
    public ResponseEntity<List<UserDTO>> getAllUsers() {
        return ResponseEntity.ok(userService.getAll());
    }

    @PostMapping
    public ResponseEntity<UserDTO> create(@RequestBody CreateUserDTO dto) {
        return new ResponseEntity<>(userService.create(dto), HttpStatus.CREATED);
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserDTO> getById(@PathVariable Long id) {
        return ResponseEntity.ok(userService.getById(id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<UserDTO> update(@PathVariable Long id, @RequestBody CreateUserDTO dto) {
        return ResponseEntity.ok(userService.update(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        userService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
