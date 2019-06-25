/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 
 See LICENSE.txt for this sample’s licensing information
 
 
 
 Abstract:
 
 Functions for performing vector math.
*/

#ifndef GLIVectorUtil_h
#define GLIVectorUtil_h

#ifdef __cplusplus
extern "C" {
#endif
    
// A Vector is floating point array with either 3 or 4 components
// functions with the vec4 prefix require 4 elements in the array
// functions with vec3 prefix require only 3 elements in the array

// Subtracts one 4D vector to another
void GLIVector4Add(float* vec, const float* lhs, const float* rhs);

// Subtracts one 4D vector from another
void GLIVector4Subtract(float* vec, const float* lhs, const float* rhs);

// Multiplys one 4D vector by another
void GLIVector4Multiply(float* vec, const float* lhs, const float* rhs);

void GLIVector4MultiplyFloat(float* vec, const float a, const float* lhs);

// Divides one 4D vector by another
void GLIVector4Divide(float* vec, const float* lhs, const float* rhs);

// Subtracts one 4D vector to another
void GLIVector3Add(float* vec, const float* lhs, const float* rhs);

// Subtracts one 4D vector from another
void GLIVector3Subtract(float* vec, const float* lhs, const float* rhs);

// Multiplys one 4D vector by another
void GLIVector3Multiply(float* vec, const float* lhs, const float* rhs);

void GLIVector3MultiplyFloat(float* vec, const float a, const float* lhs);

// Divides one 4D vector by another
void GLIVector3Divide(float* vec, const float* lhs, const float* rhs);

// Calculates the Cross Product of a 3D vector
void GLIVector3CrossProduct(float* vec, const float* lhs, const float* rhs);

// Normalizes a 3D vector
void GLIVector3Normalize(float* vec, const float* src);

// Returns the Dot Product of 2 3D vectors
float GLIVector3DotProduct(const float* lhs, const float* rhs);

// Returns the Dot Product of 2 4D vectors
float GLIVector4DotProduct(const float* lhs, const float* rhs);

// Returns the length of a 3D vector
// (i.e the distance of a point from the origin)
float GLIVector3Length(const float* vec);

// Returns the distance between two 3D points
float GLIVector3Distance(const float* pointA, const float* pointB);
    
#ifdef __cplusplus
}
#endif

#endif /* GLIVectorUtil_h */
