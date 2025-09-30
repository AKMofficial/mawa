package com.mawa.controller;
import com.mawa.model.Agency;
import com.mawa.repository.AgencyRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/agencies")
@CrossOrigin(origins = "http://localhost:3000")
public class AgencyController {

    @Autowired
    private AgencyRepository agencyRepository;

    @GetMapping
    public List<Agency> getAllAgencies() {
        return agencyRepository.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Agency> getAgencyById(@PathVariable Long id) {
        Agency agency = agencyRepository.findById(id);
        if (agency != null) {
            return ResponseEntity.ok(agency);
        }
        return ResponseEntity.notFound().build();
    }

    @PostMapping
    public Agency createAgency(@RequestBody Agency agency) {
        return agencyRepository.save(agency);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Agency> updateAgency(@PathVariable Long id, @RequestBody Agency agencyDetails) {
        Agency agency = agencyRepository.findById(id);
        if (agency != null) {
            agency.setName(agencyDetails.getName());
            agency.setCountryCode(agencyDetails.getCountryCode());
            agency.setContactPhone(agencyDetails.getContactPhone());
            return ResponseEntity.ok(agencyRepository.save(agency));
        }
        return ResponseEntity.notFound().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteAgency(@PathVariable Long id) {
        agencyRepository.deleteById(id);
        return ResponseEntity.ok().build();
    }
}