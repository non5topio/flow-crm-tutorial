package com.example.application.views.list;

import com.example.application.data.Company;
import com.example.application.data.Contact;
import com.example.application.data.Status;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicReference;
import static org.junit.jupiter.api.Assertions.assertEquals;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;


public class ContactFormTest {
    private List<Company> companies;
    private List<Status> statuses;
    private Contact marcUsher;
    private Company company1;
    private Company company2;
    private Status status1;
    private Status status2;

    @BeforeEach
    public void setupData() {
        companies = new ArrayList<>();
        company1 = new Company();
        company1.setName("Vaadin Ltd");
        company2 = new Company();
        company2.setName("IT Mill");
        companies.add(company1);
        companies.add(company2);

        statuses = new ArrayList<>();
        status1 = new Status();
        status1.setName("Status 1");
        status2 = new Status();
        status2.setName("Status 2");
        statuses.add(status1);
        statuses.add(status2);

        marcUsher = new Contact();
        marcUsher.setFirstName("Marc");
        marcUsher.setLastName("Usher");
        marcUsher.setEmail("marc@usher.com");
        marcUsher.setStatus(status1);
        marcUsher.setCompany(company2);
    }

    @Test
    public void formFieldsPopulated() {
        ContactForm form = new ContactForm(companies, statuses);
        form.setContact(marcUsher);
        assertEquals("Marc", form.firstName.getValue());
        assertEquals("Usher", form.lastName.getValue());
        assertEquals("marc@usher.com", form.email.getValue());
        assertEquals(company2, form.company.getValue());
        assertEquals(status1, form.status.getValue());
    }

    @Test
    public void saveEventHasCorrectValues() {
        ContactForm form = new ContactForm(companies, statuses);
        Contact contact = new Contact();
        form.setContact(contact);
        form.firstName.setValue("John");
        form.lastName.setValue("Doe");
        form.company.setValue(company1);
        form.email.setValue("john@doe.com");
        form.status.setValue(status2);

        AtomicReference<Contact> savedContactRef = new AtomicReference<>(null);
        form.addSaveListener(e -> {
            savedContactRef.set(e.getContact());
        });
        form.save.click();
        Contact savedContact = savedContactRef.get();

        assertEquals("John", savedContact.getFirstName());
        assertEquals("Doe", savedContact.getLastName());
        assertEquals("john@doe.com", savedContact.getEmail());
        assertEquals(company1, savedContact.getCompany());
        assertEquals(status2, savedContact.getStatus());
    }

    @Test
    public void test_form_fields_cleared_when_new_contact_is_set() {
        ContactForm form = new ContactForm(companies, statuses);
        Contact contact = new Contact();
        contact.setFirstName("John");
        contact.setLastName("Doe");
        contact.setEmail("john@doe.com");
        contact.setCompany(company1);
        contact.setStatus(status1);
        form.setContact(contact);
    
        form.setContact(new Contact());
    
        assertEquals("", form.firstName.getValue());
        assertEquals("", form.lastName.getValue());
        assertEquals("", form.email.getValue());
        assertNull(form.company.getValue());
        assertNull(form.status.getValue());
    }


    @Test
    public void test_save_button_enabled_only_when_form_is_valid() {
        ContactForm form = new ContactForm(companies, statuses);
        Contact contact = new Contact();
        form.setContact(contact);
    
        form.firstName.setValue("John");
        form.lastName.setValue("Doe");
        form.email.setValue("john@doe.com");
        form.company.setValue(company1);
        form.status.setValue(status1);
    
        assertTrue(form.save.isEnabled());
    
        form.firstName.setValue("");
        assertFalse(form.save.isEnabled());
    }


    @Test
    public void test_close_button_fires_event() {
        ContactForm form = new ContactForm(companies, statuses);
    
        AtomicReference<ContactForm> closedFormRef = new AtomicReference<>(null);
        form.addCloseListener(e -> {
            closedFormRef.set(e.getSource());
        });
        form.close.click();
        ContactForm closedForm = closedFormRef.get();
    
        assertEquals(form, closedForm);
    }


    @Test
    public void test_delete_button_fires_event() {
        ContactForm form = new ContactForm(companies, statuses);
        Contact contact = new Contact();
        form.setContact(contact);
    
        AtomicReference<Contact> deletedContactRef = new AtomicReference<>(null);
        form.addDeleteListener(e -> {
            deletedContactRef.set(e.getContact());
        });
        form.delete.click();
        Contact deletedContact = deletedContactRef.get();
    
        assertEquals(contact, deletedContact);
    }


    @Test
    public void test_set_contact_sets_bean_to_binder() {
      ContactForm form = new ContactForm(companies, statuses);
      Contact contact = new Contact();
      form.setContact(contact);
      assertEquals(contact, form.binder.getBean());
    }


    @Test
    public void test_validate_and_save_does_not_fire_save_event_when_binder_is_not_valid() {
      ContactForm form = new ContactForm(companies, statuses);
      Contact contact = new Contact();
      form.setContact(contact);
      form.firstName.setValue("");
      AtomicReference<Contact> savedContactRef = new AtomicReference<>(null);
      form.addSaveListener(e -> {
        savedContactRef.set(e.getContact());
      });
      form.save.click();
      assertNull(savedContactRef.get());
    }


    @Test
    public void test_contact_form_constructor_throws_null_pointer_exception_when_statuses_is_null() {
      assertThrows(NullPointerException.class, () -> new ContactForm(companies, null));
    }


    @Test
    public void test_contact_form_constructor_throws_null_pointer_exception_when_companies_is_null() {
      assertThrows(NullPointerException.class, () -> new ContactForm(null, statuses));
    }

}
