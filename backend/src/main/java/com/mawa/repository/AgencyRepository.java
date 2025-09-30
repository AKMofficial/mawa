package com.mawa.repository;
import com.mawa.model.Agency;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

@Repository
public class AgencyRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private final RowMapper<Agency> agencyRowMapper = new RowMapper<Agency>() {
        @Override
        public Agency mapRow(ResultSet rs, int rowNum) throws SQLException {
            Agency agency = new Agency();
            agency.setId(rs.getLong("id"));
            agency.setName(rs.getString("name"));
            agency.setCountryCode(rs.getString("country_code"));
            agency.setContactPhone(rs.getString("contact_phone"));
            return agency;
        }
    };

    public List<Agency> findAll() {
        String sql = "SELECT * FROM agency";
        return jdbcTemplate.query(sql, agencyRowMapper);
    }

    public Agency findById(Long id) {
        String sql = "SELECT * FROM agency WHERE id = ?";
        List<Agency> agencies = jdbcTemplate.query(sql, agencyRowMapper, id);
        return agencies.isEmpty() ? null : agencies.get(0);
    }

    public Agency save(Agency agency) {
        if (agency.getId() == null) {
            String sql = "INSERT INTO agency (name, country_code, contact_phone) VALUES (?, ?, ?)";
            jdbcTemplate.update(sql, agency.getName(), agency.getCountryCode(), agency.getContactPhone());
        } else {
            String sql = "UPDATE agency SET name = ?, country_code = ?, contact_phone = ? WHERE id = ?";
            jdbcTemplate.update(sql, agency.getName(), agency.getCountryCode(), agency.getContactPhone(), agency.getId());
        }
        return agency;
    }

    public void deleteById(Long id) {
        String sql = "DELETE FROM agency WHERE id = ?";
        jdbcTemplate.update(sql, id);
    }
}