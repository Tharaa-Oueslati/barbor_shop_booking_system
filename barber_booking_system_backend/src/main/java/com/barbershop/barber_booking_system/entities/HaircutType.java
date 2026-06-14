package com.barbershop.barber_booking_system.entities;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;

@Entity
@Table(name = "haircut_types")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class HaircutType {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal price;

    @Column(nullable = false)
    private Integer duration;
}
