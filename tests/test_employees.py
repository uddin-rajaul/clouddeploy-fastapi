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
