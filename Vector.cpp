#include"Vector.h"
#include<iostream>
#include<cmath>

Vector::Vector()
{
	x = 0;
	y = 0;
	z = 0;
}

Vector::Vector(const float values[])
{
	x = values[0];
	y = values[1];
	z = values[2];
}

Vector::Vector(const Vector& other)
{
	x = other.x;
	y = other.y;
	z = other.z;
}

Vector& Vector::operator=(const Vector& other)
{
	if(this != &other)
	{
		x = other.x;
		y = other.y;
		z = other.z;
	}
	return *this;
}

Vector::~Vector(){}

Vector Vector::operator+(const Vector& other)
{
	float r[3] = {other.x + x, other.y + y, other.z + z};
	return Vector(r);
}

Vector Vector::operator+(const float value)
{
	float r[3] = {x + value, y + value, z + value};
	return Vector(r);
}

Vector Vector::operator-(const Vector& other)
{
	float r[3] = {other.x - x, other.y - y, other.z - z};
	return Vector(r);
}

Vector Vector::operator-(const float value)
{
	float r[3] = {x - value, y - value, z - value};
	return Vector(r);
}

Vector Vector::operator/(const float value)
{
	float r[3] = {x / value, y / value, z / value};
	return Vector(r);
}

Vector& Vector::operator+=(const Vector& other)
{
	x += other.x;
	y += other.y;
	z += other.z;
	return *this;
}

Vector& Vector::operator+=(const float value)
{
	x += value;
	y += value;
	z += value;
	return *this;
}

Vector& Vector::operator-=(const Vector& other)
{
	x -= other.x;
	y -= other.y;
	z -= other.z;
	return *this;
}

Vector& Vector::operator-=(const float value)
{
	x -= value;
	y -= value;
	z -= value;
	return *this;
}

Vector& Vector::operator/=(const float value)
{
	x /= value;
	y /= value;
	z /= value;
	return *this;
}

float Vector::operator*(const Vector& other)
{
	return x * other.x + y * other.y + z * other.z;
}

Vector Vector::operator%(const Vector& other)
{
	float r[3] = {y * other.z - z * other.y, z * other.x - x * other.z, x * other.y - y * other.x};
	return Vector(r);
}

float Vector::operator[](const int index)
{
	switch(index)
	{
	case 0:
		return x;
	case 1:
		return y;
	case 2:
		return z;
	default:
		return 0;
	}
}

Vector::operator double()
{
	return std::sqrt(x * x + y * y + z * z);
}

void Vector::print(std::ostream& o) const
{
	o << "x: " << x << " y: " << y << " z: " << z << std::endl;
}