def test_create_employee(client):
    response = client.post(
        "/employees",
        json={
            "name": "Alice Smith",
            "email": "alice@example.com",
            "department": "Engineering",
            "job_title": "Software Engineer",
        },
    )

    assert response.status_code == 201

    data = response.json()

    assert data["name"] == "Alice Smith"
    assert data["email"] == "alice@example.com"
    assert data["department"] == "Engineering"
    assert data["job_title"] == "Software Engineer"
    assert data["is_active"] is True
    assert "id" in data
    assert "created_at" in data
    assert "updated_at" in data


def create_employee(client, **overrides):
    payload = {
        "name": "Alice Smith",
        "email": "alice@example.com",
        "department": "Engineering",
        "job_title": "Software Engineer",
    }
    payload.update(overrides)
    return client.post("/employees", json=payload)


def test_list_employees(client):
    create_employee(client, email="alice@example.com")
    create_employee(client, email="bob@example.com", name="Bob Jones")

    response = client.get("/employees")

    assert response.status_code == 200

    employees = response.json()

    assert len(employees) == 2

    emails = {employee["email"] for employee in employees}

    assert emails == {"alice@example.com", "bob@example.com"}


def test_get_employee_by_id(client):
    create_response = create_employee(client)
    employee_id = create_response.json()["id"]

    response = client.get(f"/employees/{employee_id}")

    assert response.status_code == 200

    data = response.json()

    assert data["id"] == employee_id
    assert data["name"] == "Alice Smith"
    assert data["email"] == "alice@example.com"
    assert data["department"] == "Engineering"
    assert data["job_title"] == "Software Engineer"


def test_get_nonexistent_employee(client):
    response = client.get("/employees/999999")

    assert response.status_code == 404


def test_update_employee(client):
    create_response = create_employee(client)
    employee_id = create_response.json()["id"]

    response = client.put(
        f"/employees/{employee_id}",
        json={
            "name": "Alice Smith Updated",
            "department": "Product",
        },
    )

    assert response.status_code == 200

    data = response.json()

    assert data["name"] == "Alice Smith Updated"
    assert data["department"] == "Product"
    assert data["email"] == "alice@example.com"
    assert data["job_title"] == "Software Engineer"


def test_delete_employee(client):
    create_response = create_employee(client)
    employee_id = create_response.json()["id"]

    delete_response = client.delete(f"/employees/{employee_id}")

    assert delete_response.status_code == 200
    assert delete_response.json() == {"message": "Employee deleted successfully"}

    get_response = client.get(f"/employees/{employee_id}")

    assert get_response.status_code == 404


def test_create_employee_invalid_input(client):
    response = client.post(
        "/employees",
        json={
            "name": "Missing Department",
            "email": "missing@example.com",
            "job_title": "Engineer",
        },
    )

    assert response.status_code == 422


def test_create_employee_duplicate_email(client):
    create_employee(client)

    response = create_employee(client, name="Second Alice")

    assert response.status_code == 409
    assert response.json() == {"detail": "Employee with this email already exists"}


def test_update_nonexistent_employee(client):
    response = client.put(
        "/employees/999999",
        json={"name": "Ghost"},
    )

    assert response.status_code == 404
