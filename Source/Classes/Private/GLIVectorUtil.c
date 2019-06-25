/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 
 See LICENSE.txt for this sample’s licensing information
 
 
 
 Abstract:
 
 Functions for performing vector math.
*/

#include "GLIVectorUtil.h"
#include <math.h>
#include <memory.h>

void GLIVector4Add(float* vec, const float* lhs, const float* rhs) {
    vec[0] = lhs[0] + rhs[0];
    vec[1] = lhs[1] + rhs[1];
    vec[2] = lhs[2] + rhs[2];
    vec[3] = lhs[3] + rhs[3];
}

void GLIVector4Subtract(float* vec, const float* lhs, const float* rhs) {
    vec[0] = lhs[0] - rhs[0];
    vec[1] = lhs[1] - rhs[1];
    vec[2] = lhs[2] - rhs[2];
    vec[3] = lhs[3] - rhs[3];
}


void GLIVector4Multiply(float* vec, const float* lhs, const float* rhs) {
    vec[0] = lhs[0] * rhs[0];
    vec[1] = lhs[1] * rhs[1];
    vec[2] = lhs[2] * rhs[2];
    vec[3] = lhs[3] * rhs[3];
}

void GLIVector4MultiplyFloat(float* vec, const float a, const float* lhs)
{
    vec[0] = a * lhs[0];
    vec[1] = a * lhs[1];
    vec[2] = a * lhs[2];
    vec[3] = a * lhs[3];
}

void GLIVector4Divide(float* vec, const float* lhs, const float* rhs) {
    vec[0] = lhs[0] / rhs[0];
    vec[1] = lhs[1] / rhs[1];
    vec[2] = lhs[2] / rhs[2];
    vec[3] = lhs[3] / rhs[3];
}


void GLIVector3Add(float* vec, const float* lhs, const float* rhs) {
    vec[0] = lhs[0] + rhs[0];
    vec[1] = lhs[1] + rhs[1];
    vec[2] = lhs[2] + rhs[2];
}

void GLIVector3Subtract(float* vec, const float* lhs, const float* rhs) {
    vec[0] = lhs[0] - rhs[0];
    vec[1] = lhs[1] - rhs[1];
    vec[2] = lhs[2] - rhs[2];
}


void GLIVector3Multiply(float* vec, const float* lhs, const float* rhs) {
    vec[0] = lhs[0] * rhs[0];
    vec[1] = lhs[1] * rhs[1];
    vec[2] = lhs[2] * rhs[2];
}

void GLIVector3MultiplyFloat(float* vec, const float a, const float* lhs)
{
    vec[0] = a * lhs[0];
    vec[1] = a * lhs[1];
    vec[2] = a * lhs[2];
}

void GLIVector3Divide(float* vec, const float* lhs, const float* rhs) {
    vec[0] = lhs[0] / rhs[0];
    vec[1] = lhs[1] / rhs[1];
    vec[2] = lhs[2] / rhs[2];
}

float GLIVector3DotProduct(const float* lhs, const float* rhs) {
    return lhs[0] * rhs[0] + lhs[1] * rhs[1] + lhs[2] * rhs[2];
}

float GLIVector4DotProduct(const float* lhs, const float* rhs) {
    return lhs[0] * rhs[0] + lhs[1] * rhs[1] + lhs[2] * rhs[2] + lhs[3] * rhs[3];
}

void GLIVector3CrossProduct(float* vec, const float* lhs, const float* rhs) {
    vec[0] = lhs[1] * rhs[2] - lhs[2] * rhs[1];
    vec[1] = lhs[2] * rhs[0] - lhs[0] * rhs[2];
    vec[2] = lhs[0] * rhs[1] - lhs[1] * rhs[0];
}

float GLIVector3Length(const float* vec) {
    return sqrtf(vec[0] * vec[0] + vec[1] * vec[1] + vec[2] * vec[2]);
}

float GLIVector3Distance(const float* pointA, const float* pointB) {
    float diffx = pointA[0] - pointB[0];
    float diffy = pointA[1] - pointB[1];
    float diffz = pointA[2] - pointB[2];
    return sqrtf(diffx * diffx + diffy * diffy + diffz * diffz);
}

void GLIVector3Normalize(float* vec, const float* src) {
    float length = GLIVector3Length(src);
    
    vec[0] = src[0] / length;
    vec[1] = src[1] / length;
    vec[2] = src[2] / length;
}
