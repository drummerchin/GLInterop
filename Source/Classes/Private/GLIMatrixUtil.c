/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Functions for performing matrix math.
*/

#include "GLIMatrixUtil.h"
#include "GLIVectorUtil.h"
#include <math.h>
#include <memory.h>

void GLIMatrixLoadFromColumns(float *m, float c00, float c10, float c20, float c30,
                             float c01, float c11, float c21, float c31,
                             float c02, float c12, float c22, float c32,
                             float c03, float c13, float c23, float c33)
{
    m[0] = c00;
    m[1] = c01;
    m[2] = c02;
    m[3] = c03;
    m[4] = c10;
    m[5] = c11;
    m[6] = c12;
    m[7] = c13;
    m[8] = c20;
    m[9] = c21;
    m[10] = c22;
    m[11] = c23;
    m[12] = c30;
    m[13] = c31;
    m[14] = c32;
    m[15] = c33;
}

void GLIMatrix3x3LoadFromColumns(float *m, float c00, float c10, float c20,
                                float c01, float c11, float c21,
                                float c02, float c12, float c22)
{
    m[0] = c00;
    m[1] = c01;
    m[2] = c02;
    m[3] = c10;
    m[4] = c11;
    m[5] = c12;
    m[6] = c20;
    m[7] = c21;
    m[8] = c22;
}

void GLIMatrixLoadFromRows(float *m, float r00, float r01, float r02, float r03,
                                      float r10, float r11, float r12, float r13,
                                      float r20, float r21, float r22, float r23,
                                      float r30, float r31, float r32, float r33)
{
    m[0] = r00;
    m[1] = r10;
    m[2] = r20;
    m[3] = r30;
    m[4] = r01;
    m[5] = r11;
    m[6] = r21;
    m[7] = r31;
    m[8] = r02;
    m[9] = r12;
    m[10] = r22;
    m[11] = r32;
    m[12] = r03;
    m[13] = r13;
    m[14] = r23;
    m[15] = r33;
}

void GLIMatrix3x3LoadFromRows(float *m, float r00, float r01, float r02,
                                         float r10, float r11, float r12,
                                         float r20, float r21, float r22)
{
    m[0] = r00;
    m[1] = r10;
    m[2] = r20;
    m[3] = r01;
    m[4] = r11;
    m[5] = r21;
    m[6] = r02;
    m[7] = r12;
    m[8] = r22;
}


void GLIMatrixLinearCombination(float *m, float a, const float *lhs, float b, const float *rhs)
{
    float tempL[4];
    float tempR[4];
    
    GLIVector4MultiplyFloat(tempL, a, &lhs[0]);
    GLIVector4MultiplyFloat(tempR, b, &rhs[0]);
    GLIVector4Add(&m[0], tempL, tempR);

    GLIVector4MultiplyFloat(tempL, a, &lhs[4]);
    GLIVector4MultiplyFloat(tempR, b, &rhs[4]);
    GLIVector4Add(&m[4], tempL, tempR);

    GLIVector4MultiplyFloat(tempL, a, &lhs[8]);
    GLIVector4MultiplyFloat(tempR, b, &rhs[8]);
    GLIVector4Add(&m[8], tempL, tempR);

    GLIVector4MultiplyFloat(tempL, a, &lhs[12]);
    GLIVector4MultiplyFloat(tempR, b, &rhs[12]);
    GLIVector4Add(&m[12], tempL, tempR);
}

void GLIMatrix3x3LinearCombination(float *m, float a, const float *lhs, float b, const float *rhs)
{
    float tempL[3];
    float tempR[3];
    
    GLIVector3MultiplyFloat(tempL, a, &lhs[0]);
    GLIVector3MultiplyFloat(tempR, b, &rhs[0]);
    GLIVector3Add(&m[0], tempL, tempR);

    GLIVector3MultiplyFloat(tempL, a, &lhs[3]);
    GLIVector3MultiplyFloat(tempR, b, &rhs[3]);
    GLIVector3Add(&m[3], tempL, tempR);

    GLIVector3MultiplyFloat(tempL, a, &lhs[6]);
    GLIVector3MultiplyFloat(tempR, b, &rhs[6]);
    GLIVector3Add(&m[6], tempL, tempR);
}

void GLIMatrixMultiply(float* ret, const float* lhs, const float* rhs) {
    // [ 0 4  8 12 ]   [ 0 4  8 12 ]
    // [ 1 5  9 13 ] x [ 1 5  9 13 ]
    // [ 2 6 10 14 ]   [ 2 6 10 14 ]
    // [ 3 7 11 15 ]   [ 3 7 11 15 ]
    ret[0] = lhs[0] * rhs[0] + lhs[4] * rhs[1] + lhs[8] * rhs[2] + lhs[12] * rhs[3];
    ret[1] = lhs[1] * rhs[0] + lhs[5] * rhs[1] + lhs[9] * rhs[2] + lhs[13] * rhs[3];
    ret[2] = lhs[2] * rhs[0] + lhs[6] * rhs[1] + lhs[10] * rhs[2] + lhs[14] * rhs[3];
    ret[3] = lhs[3] * rhs[0] + lhs[7] * rhs[1] + lhs[11] * rhs[2] + lhs[15] * rhs[3];
    
    ret[4] = lhs[0] * rhs[4] + lhs[4] * rhs[5] + lhs[8] * rhs[6] + lhs[12] * rhs[7];
    ret[5] = lhs[1] * rhs[4] + lhs[5] * rhs[5] + lhs[9] * rhs[6] + lhs[13] * rhs[7];
    ret[6] = lhs[2] * rhs[4] + lhs[6] * rhs[5] + lhs[10] * rhs[6] + lhs[14] * rhs[7];
    ret[7] = lhs[3] * rhs[4] + lhs[7] * rhs[5] + lhs[11] * rhs[6] + lhs[15] * rhs[7];
    
    ret[8] = lhs[0] * rhs[8] + lhs[4] * rhs[9] + lhs[8] * rhs[10] + lhs[12] * rhs[11];
    ret[9] = lhs[1] * rhs[8] + lhs[5] * rhs[9] + lhs[9] * rhs[10] + lhs[13] * rhs[11];
    ret[10] = lhs[2] * rhs[8] + lhs[6] * rhs[9] + lhs[10] * rhs[10] + lhs[14] * rhs[11];
    ret[11] = lhs[3] * rhs[8] + lhs[7] * rhs[9] + lhs[11] * rhs[10] + lhs[15] * rhs[11];
    
    ret[12] = lhs[0] * rhs[12] + lhs[4] * rhs[13] + lhs[8] * rhs[14] + lhs[12] * rhs[15];
    ret[13] = lhs[1] * rhs[12] + lhs[5] * rhs[13] + lhs[9] * rhs[14] + lhs[13] * rhs[15];
    ret[14] = lhs[2] * rhs[12] + lhs[6] * rhs[13] + lhs[10] * rhs[14] + lhs[14] * rhs[15];
    ret[15] = lhs[3] * rhs[12] + lhs[7] * rhs[13] + lhs[11] * rhs[14] + lhs[15] * rhs[15];
}


void GLIMatrixLoadPerspective(float* m, float fov, float aspect, float nearZ,
                        float farZ) {
    float f = 1.0f / tanf((fov * (M_PI / 180)) / 2.0f);
    
    m[0] = f / aspect;
    m[1] = 0.0f;
    m[2] = 0.0f;
    m[3] = 0.0f;
    
    m[4] = 0.0f;
    m[5] = f;
    m[6] = 0.0f;
    m[7] = 0.0f;
    
    m[8] = 0.0f;
    m[9] = 0.0f;
    m[10] = (farZ + nearZ) / (nearZ - farZ);
    m[11] = -1.0f;
    
    m[12] = 0.0f;
    m[13] = 0.0f;
    m[14] = 2 * farZ * nearZ / (nearZ - farZ);
    m[15] = 0.0f;
}


void GLIMatrixLoadOrthographic(float* m, float left, float right, float bottom, float top, float nearZ, float farZ) {

    m[0] = 2.0f / (right - left);
    m[1] = 0.0;
    m[2] = 0.0;
    m[3] = 0.0;
    
    m[4] = 0.0;
    m[5] = 2.0f / (top - bottom);
    m[6] = 0.0;
    m[7] = 0.0;
    
    m[8] = 0.0;
    m[9] = 0.0;
    m[10] = -2.0f / (farZ - nearZ);
    m[11] = 0.0;
    
    m[12] = 0.0;
    m[13] = 0.0;
    m[14] = -1.0 * nearZ / (farZ - nearZ);
    m[15] = 1.0f;
}

void GLIMatrixLoadOrthographicOffCenter(float* m, float left, float right, float bottom, float top, float nearZ, float farZ)
{
    //See appendix G of OpenGL Red Book
    
    m[0] = 2.0f / (right - left);
    m[1] = 0.0;
    m[2] = 0.0;
    m[3] = 0.0;
    
    m[4] = 0.0;
    m[5] = 2.0f / (top - bottom);
    m[6] = 0.0;
    m[7] = 0.0;
    
    m[8] = 0.0;
    m[9] = 0.0;
    m[10] = -2.0f / (farZ - nearZ);
    m[11] = 0.0;
    
    m[12] = -(right + left) / (right - left);
    m[13] = -(top + bottom) / (top - bottom);
    m[14] = -(farZ + nearZ) / (farZ - nearZ);
    m[15] = 1.0f;
}

static inline float sgn(float val) {
    return (val > 0.0f) ? 1.0f : ((val < 0.0f) ? -1.0f : 0.0f);
}

void GLIMatrixModifyObliqueProjection(float* m, const float* src,
                                const float* plane) {
    float vec[4];
    
    memcpy(m, src, 16 * sizeof(float));
    
    vec[0] = (sgn(plane[0]) + m[8]) / m[0];
    vec[1] = (sgn(plane[1]) + m[9]) / m[5];
    vec[2] = -1.0f;
    vec[3] = (1.0f + m[10]) / m[14];
    
    float dot = GLIVector4DotProduct(plane, vec);
    
    vec[0] = plane[0] * (2.0f / dot);
    vec[1] = plane[1] * (2.0f / dot);
    vec[2] = plane[2] * (2.0f / dot);
    vec[3] = plane[3] * (2.0f / dot);
    
    // Replace the third row of the projection matrix
    m[2] = vec[0];
    m[6] = vec[1];
    m[10] = vec[2];
    m[14] = vec[3];
}

void GLIMatrixTranspose(float* m, const float* src) {
    //Use a temp to swap in case m == src
    
    float tmp;
    m[0] = src[0];
    m[5] = src[5];
    m[10] = src[10];
    m[15] = src[15];
    
    tmp = src[4];
    m[4] = src[1];
    m[1] = tmp;
    
    tmp = src[8];
    m[8] = src[2];
    m[2] = tmp;
    
    tmp = src[12];
    m[12] = src[3];
    m[3] = tmp;
    
    tmp = src[9];
    m[9] = src[6];
    m[6] = tmp;
    
    tmp = src[13];
    m[13] = src[7];
    m[7] = tmp;
    
    tmp = src[14];
    m[14] = src[11];
    m[11] = tmp;
}

void GLIMatrixInvert(float* m, const float* src) {
    float tmp[16];
    float val, val2, val_inv;
    int i, j, i4, i8, i12, ind;
    
    GLIMatrixTranspose(tmp, src);
    
    GLIMatrixLoadIdentity(m);
    
    for (i = 0; i != 4; i++) {
        val = tmp[(i << 2) + i];
        ind = i;
        
        i4 = i + 4;
        i8 = i + 8;
        i12 = i + 12;
        
        for (j = i + 1; j != 4; j++) {
            if (fabsf(tmp[(i << 2) + j]) > fabsf(val)) {
                ind = j;
                val = tmp[(i << 2) + j];
            }
        }
        
        if (ind != i) {
            val2 = m[i];
            m[i] = m[ind];
            m[ind] = val2;
            
            val2 = tmp[i];
            tmp[i] = tmp[ind];
            tmp[ind] = val2;
            
            ind += 4;
            
            val2 = m[i4];
            m[i4] = m[ind];
            m[ind] = val2;
            
            val2 = tmp[i4];
            tmp[i4] = tmp[ind];
            tmp[ind] = val2;
            
            ind += 4;
            
            val2 = m[i8];
            m[i8] = m[ind];
            m[ind] = val2;
            
            val2 = tmp[i8];
            tmp[i8] = tmp[ind];
            tmp[ind] = val2;
            
            ind += 4;
            
            val2 = m[i12];
            m[i12] = m[ind];
            m[ind] = val2;
            
            val2 = tmp[i12];
            tmp[i12] = tmp[ind];
            tmp[ind] = val2;
        }
        
        if (val == 0) {
            GLIMatrixLoadIdentity(m);
            return;
        }
        
        val_inv = 1.0f / val;
        
        tmp[i] *= val_inv;
        m[i] *= val_inv;
        
        tmp[i4] *= val_inv;
        m[i4] *= val_inv;
        
        tmp[i8] *= val_inv;
        m[i8] *= val_inv;
        
        tmp[i12] *= val_inv;
        m[i12] *= val_inv;
        
        if (i != 0) {
            val = tmp[i << 2];
            
            tmp[0] -= tmp[i] * val;
            m[0] -= m[i] * val;
            
            tmp[4] -= tmp[i4] * val;
            m[4] -= m[i4] * val;
            
            tmp[8] -= tmp[i8] * val;
            m[8] -= m[i8] * val;
            
            tmp[12] -= tmp[i12] * val;
            m[12] -= m[i12] * val;
        }
        
        if (i != 1) {
            val = tmp[(i << 2) + 1];
            
            tmp[1] -= tmp[i] * val;
            m[1] -= m[i] * val;
            
            tmp[5] -= tmp[i4] * val;
            m[5] -= m[i4] * val;
            
            tmp[9] -= tmp[i8] * val;
            m[9] -= m[i8] * val;
            
            tmp[13] -= tmp[i12] * val;
            m[13] -= m[i12] * val;
        }
        
        if (i != 2) {
            val = tmp[(i << 2) + 2];
            
            tmp[2] -= tmp[i] * val;
            m[2] -= m[i] * val;
            
            tmp[6] -= tmp[i4] * val;
            m[6] -= m[i4] * val;
            
            tmp[10] -= tmp[i8] * val;
            m[10] -= m[i8] * val;
            
            tmp[14] -= tmp[i12] * val;
            m[14] -= m[i12] * val;
        }
        
        if (i != 3) {
            val = tmp[(i << 2) + 3];
            
            tmp[3] -= tmp[i] * val;
            m[3] -= m[i] * val;
            
            tmp[7] -= tmp[i4] * val;
            m[7] -= m[i4] * val;
            
            tmp[11] -= tmp[i8] * val;
            m[11] -= m[i8] * val;
            
            tmp[15] -= tmp[i12] * val;
            m[15] -= m[i12] * val;
        }
    }
}

void GLIMatrixLoadIdentity(float* m) {
    // [ 0 4  8 12 ]
    // [ 1 5  9 13 ]
    // [ 2 6 10 14 ]
    // [ 3 7 11 15 ]
    m[0] = m[5] = m[10] = m[15] = 1.0f;
    
    m[1] = m[2] = m[3] = m[4] =
    m[6] = m[7] = m[8] = m[9] =
    m[11] = m[12] = m[13] = m[14] = 0.0;
}

void GLIMatrixLoadCATransform3D(float *m, CATransform3D t)
{
    m[0] = t.m11;
    m[1] = t.m12;
    m[2] = t.m13;
    m[3] = t.m14;
    m[4] = t.m21;
    m[5] = t.m22;
    m[6] = t.m23;
    m[7] = t.m24;
    m[8] = t.m31;
    m[9] = t.m32;
    m[10] = t.m33;
    m[11] = t.m34;
    m[12] = t.m41;
    m[13] = t.m42;
    m[14] = t.m43;
    m[15] = t.m44;
}

void GLIMatrixLoadDiagonal(float *m, float *vec4)
{
    m[0] = vec4[0];
    m[5] = vec4[1];
    m[10] = vec4[2];
    m[15] = vec4[3];

    m[1] = m[2] = m[3] = m[4] =
    m[6] = m[7] = m[8] = m[9] =
    m[11] = m[12] = m[13] = m[14] = 0.0;
}


void GLIMatrixLoadTranslate(float* m, float xTrans, float yTrans, float zTrans) {
    
    // [ 0 4  8  x ]
    // [ 1 5  9  y ]
    // [ 2 6 10  z ]
    // [ 3 7 11 15 ]
    m[0] = m[5] = m[10] = m[15] = 1.0f;
    
    m[1] = m[2] = m[3] = m[4] = m[6]
    = m[7] = m[8] = m[9] = m[11] = 0.0;
    
    m[12] = xTrans;
    m[13] = yTrans;
    m[14] = zTrans;
}


void GLIMatrixLoadScale(float* m, float xScale, float yScale, float zScale) {
    // [ x 4  8 12 ]
    // [ 1 y  9 13 ]
    // [ 2 6  z 14 ]
    // [ 3 7 11 15 ]
    m[0] = xScale;
    m[5] = yScale;
    m[10] = zScale;
    m[15] = 1.0f;
    
    m[1] = m[2] = m[3] = m[4] =
    m[6] = m[7] = m[8] = m[9] =
    m[11] = m[12] = m[13] = m[14] = 0.0;
}


void GLIMatrixLoadRotateX(float* m, float rad) {
    // [ 0 4      8 12 ]
    // [ 1 cos -sin 13 ]
    // [ 2 sin cos  14 ]
    // [ 3 7     11 15 ]
    
    m[10] = m[5] = cosf(rad);
    m[6] = sinf(rad);
    m[9] = -m[6];
    
    m[0] = m[15] = 1.0f;
    
    m[1] = m[2] = m[3] = m[4] =
    m[7] = m[8] = m[11] = m[12] =
    m[13] = m[14] = 0.0;
}


void GLIMatrixLoadRotateY(float* m, float rad) {
    // [ cos 4  -sin 12 ]
    // [ 1   5   9   13 ]
    // [ sin 6  cos  14 ]
    // [ 3   7  11   15 ]
    
    m[0] = m[10] = cosf(rad);
    m[2] = sinf(rad);
    m[8] = -m[2];
    
    m[5] = m[15] = 1.0;
    
    m[1] = m[3] = m[4] = m[6] =
    m[7] = m[9] = m[11] = m[12] =
    m[13] = m[14] = 0.0;
}


void GLIMatrixLoadRotateZ(float* m, float rad) {
    // [ cos -sin 8 12 ]
    // [ sin cos  9 13 ]
    // [ 2   6   10 14 ]
    // [ 3   7   11 15 ]
    
    m[0] = m[5] = cosf(rad);
    m[1] = sinf(rad);
    m[4] = -m[1];
    
    m[10] = m[15] = 1.0;
    
    m[2] = m[3] = m[6] = m[7] =
    m[8] = m[9] = m[11] = m[12] =
    m[13] = m[14] = 0.0;
}


void GLIMatrixLoadRotate(float* m, float deg, float xAxis, float yAxis,
                   float zAxis) {
    float rad = deg * M_PI / 180.0f;
    
    float sin_a = sinf(rad);
    float cos_a = cosf(rad);
    
    // Calculate coeffs.  No need to check for zero magnitude because we wouldn't be here.
    float magnitude = sqrtf(xAxis * xAxis + yAxis * yAxis + zAxis * zAxis);
    
    float p = 1.0f / magnitude;
    float cos_am = 1.0f - cos_a;
    
    float xp = xAxis * p;
    float yp = yAxis * p;
    float zp = zAxis * p;
    
    float xx = xp * xp;
    float yy = yp * yp;
    float zz = zp * zp;
    
    float xy = xp * yp * cos_am;
    float yz = yp * zp * cos_am;
    float zx = zp * xp * cos_am;
    
    xp *= sin_a;
    yp *= sin_a;
    zp *= sin_a;
    
    // Load coefs
    float m0 = xx + cos_a * (1.0f - xx);
    float m1 = xy + zp;
    float m2 = zx - yp;
    float m4 = xy - zp;
    float m5 = yy + cos_a * (1.0f - yy);
    float m6 = yz + xp;
    float m8 = zx + yp;
    float m9 = yz - xp;
    float m10 = zz + cos_a * (1.0f - zz);
    
    // Apply rotation
    float c1 = m[0];
    float c2 = m[4];
    float c3 = m[8];
    m[0] = c1 * m0 + c2 * m1 + c3 * m2;
    m[4] = c1 * m4 + c2 * m5 + c3 * m6;
    m[8] = c1 * m8 + c2 * m9 + c3 * m10;
    
    c1 = m[1];
    c2 = m[5];
    c3 = m[9];
    m[1] = c1 * m0 + c2 * m1 + c3 * m2;
    m[5] = c1 * m4 + c2 * m5 + c3 * m6;
    m[9] = c1 * m8 + c2 * m9 + c3 * m10;
    
    c1 = m[2];
    c2 = m[6];
    c3 = m[10];
    m[2] = c1 * m0 + c2 * m1 + c3 * m2;
    m[6] = c1 * m4 + c2 * m5 + c3 * m6;
    m[10] = c1 * m8 + c2 * m9 + c3 * m10;
    
    c1 = m[3];
    c2 = m[7];
    c3 = m[11];
    m[3] = c1 * m0 + c2 * m1 + c3 * m2;
    m[7] = c1 * m4 + c2 * m5 + c3 * m6;
    m[11] = c1 * m8 + c2 * m9 + c3 * m10;
    
    m[12] = m[13] = m[14] = 0.0;
    m[15] = 1.0f;
}


void GLIMatrixTranslateApply(float* m, float xTrans, float yTrans, float zTrans) {
    // [ 0 4  8 12 ]   [ 1 0 0 x ]
    // [ 1 5  9 13 ] x [ 0 1 0 y ]
    // [ 2 6 10 14 ]   [ 0 0 1 z ]
    // [ 3 7 11 15 ]   [ 0 0 0 1 ]
    
    m[12] += m[0] * xTrans + m[4] * yTrans + m[8] * zTrans;
    m[13] += m[1] * xTrans + m[5] * yTrans + m[9] * zTrans;
    m[14] += m[2] * xTrans + m[6] * yTrans + m[10] * zTrans;
}


void GLIMatrixScaleApply(float* m, float xScale, float yScale, float zScale) {
    // [ 0 4  8 12 ]   [ x 0 0 0 ]
    // [ 1 5  9 13 ] x [ 0 y 0 0 ]
    // [ 2 6 10 14 ]   [ 0 0 z 0 ]
    // [ 3 7 11 15 ]   [ 0 0 0 1 ]
    
    m[0] *= xScale;
    m[4] *= yScale;
    m[8] *= zScale;
    
    m[1] *= xScale;
    m[5] *= yScale;
    m[9] *= zScale;
    
    m[2] *= xScale;
    m[6] *= yScale;
    m[10] *= zScale;
    
    m[3] *= xScale;
    m[7] *= yScale;
    m[11] *= xScale;
}


void GLIMatrixTranslateMatrix(float* m, float xTrans, float yTrans, float zTrans) {
    // [ 1 0 0 x ]   [ 0 4  8 12 ]
    // [ 0 1 0 y ] x [ 1 5  9 13 ]
    // [ 0 0 1 z ]   [ 2 6 10 14 ]
    // [ 0 0 0 1 ]   [ 3 7 11 15 ]
    
    m[0] += xTrans * m[3];
    m[1] += yTrans * m[3];
    m[2] += zTrans * m[3];
    
    m[4] += xTrans * m[7];
    m[5] += yTrans * m[7];
    m[6] += zTrans * m[7];
    
    m[8] += xTrans * m[11];
    m[9] += yTrans * m[11];
    m[10] += zTrans * m[11];
    
    m[12] += xTrans * m[15];
    m[13] += yTrans * m[15];
    m[14] += zTrans * m[15];
}


void GLIMatrixRotateXApply(float* m, float deg) {
    // [ 0 4  8 12 ]   [ 1  0    0  0 ]
    // [ 1 5  9 13 ] x [ 0 cos -sin 0 ]
    // [ 2 6 10 14 ]   [ 0 sin  cos 0 ]
    // [ 3 7 11 15 ]   [ 0  0    0  1 ]
    
    float rad = deg * (M_PI / 180.0f);
    
    float cosrad = cosf(rad);
    float sinrad = sinf(rad);
    
    float m04 = m[4];
    float m05 = m[5];
    float m06 = m[6];
    float m07 = m[7];
    
    m[4] = m[8] * sinrad + m04 * cosrad;
    m[8] = m[8] * cosrad - m04 * sinrad;
    
    m[5] = m[9] * sinrad + m05 * cosrad;
    m[9] = m[9] * cosrad - m05 * sinrad;
    
    m[6] = m[10] * sinrad + m06 * cosrad;
    m[10] = m[10] * cosrad - m06 * sinrad;
    
    m[7] = m[11] * sinrad + m07 * cosrad;
    m[11] = m[11] * cosrad - m07 * sinrad;
}


void GLIMatrixRotateYApply(float* m, float deg) {
    // [ 0 4  8 12 ]   [ cos 0  -sin 0 ]
    // [ 1 5  9 13 ] x [ 0   1  0    0 ]
    // [ 2 6 10 14 ]   [ sin 0  cos  0 ]
    // [ 3 7 11 15 ]   [ 0   0  0    1 ]
    
    float rad = deg * (M_PI / 180.0f);
    
    float cosrad = cosf(rad);
    float sinrad = sinf(rad);
    
    float m00 = m[0];
    float m01 = m[1];
    float m02 = m[2];
    float m03 = m[3];
    
    m[0] = m[8] * sinrad + m00 * cosrad;
    m[8] = m[8] * cosrad - m00 * sinrad;
    
    m[1] = m[9] * sinrad + m01 * cosrad;
    m[9] = m[9] * cosrad - m01 * sinrad;
    
    m[2] = m[10] * sinrad + m02 * cosrad;
    m[10] = m[10] * cosrad - m02 * sinrad;
    
    m[3] = m[11] * sinrad + m03 * cosrad;
    m[11] = m[11] * cosrad - m03 * sinrad;
}


void GLIMatrixRotateZApply(float* m, float deg) {
    // [ 0 4  8 12 ]   [ cos -sin 0  0 ]
    // [ 1 5  9 13 ] x [ sin cos  0  0 ]
    // [ 2 6 10 14 ]   [ 0   0    1  0 ]
    // [ 3 7 11 15 ]   [ 0   0    0  1 ]
    
    float rad = deg * (M_PI / 180.0f);
    
    float cosrad = cosf(rad);
    float sinrad = sinf(rad);
    
    float m00 = m[0];
    float m01 = m[1];
    float m02 = m[2];
    float m03 = m[3];
    
    m[0] = m[4] * sinrad + m00 * cosrad;
    m[4] = m[4] * cosrad - m00 * sinrad;
    
    m[1] = m[5] * sinrad + m01 * cosrad;
    m[5] = m[5] * cosrad - m01 * sinrad;
    
    m[2] = m[6] * sinrad + m02 * cosrad;
    m[6] = m[6] * cosrad - m02 * sinrad;
    
    m[3] = m[7] * sinrad + m03 * cosrad;
    m[7] = m[7] * cosrad - m03 * sinrad;
}

void GLIMatrixRotateApply(float* m, float deg, float xAxis, float yAxis, float zAxis) {
    if (yAxis == 0.0f && zAxis == 0.0f) {
        GLIMatrixRotateXApply(m, deg);
    }
    else if (xAxis == 0.0f && zAxis == 0.0f) {
        GLIMatrixRotateYApply(m, deg);
    }
    else if (xAxis == 0.0f && yAxis == 0.0f) {
        GLIMatrixRotateZApply(m, deg);
    }
    else {
        float rad = deg * M_PI / 180.0f;
        
        float sin_a = sinf(rad);
        float cos_a = cosf(rad);
        
        // Calculate coeffs.  No need to check for zero magnitude because we wouldn't be here.
        float magnitude = sqrtf(xAxis * xAxis + yAxis * yAxis + zAxis * zAxis);
        
        float p = 1.0f / magnitude;
        float cos_am = 1.0f - cos_a;
        
        float xp = xAxis * p;
        float yp = yAxis * p;
        float zp = zAxis * p;
        
        float xx = xp * xp;
        float yy = yp * yp;
        float zz = zp * zp;
        
        float xy = xp * yp * cos_am;
        float yz = yp * zp * cos_am;
        float zx = zp * xp * cos_am;
        
        xp *= sin_a;
        yp *= sin_a;
        zp *= sin_a;
        
        // Load coefs
        float m0 = xx + cos_a * (1.0f - xx);
        float m1 = xy + zp;
        float m2 = zx - yp;
        float m4 = xy - zp;
        float m5 = yy + cos_a * (1.0f - yy);
        float m6 = yz + xp;
        float m8 = zx + yp;
        float m9 = yz - xp;
        float m10 = zz + cos_a * (1.0f - zz);
        
        // Apply rotation
        float c1 = m[0];
        float c2 = m[4];
        float c3 = m[8];
        m[0] = c1 * m0 + c2 * m1 + c3 * m2;
        m[4] = c1 * m4 + c2 * m5 + c3 * m6;
        m[8] = c1 * m8 + c2 * m9 + c3 * m10;
        
        c1 = m[1];
        c2 = m[5];
        c3 = m[9];
        m[1] = c1 * m0 + c2 * m1 + c3 * m2;
        m[5] = c1 * m4 + c2 * m5 + c3 * m6;
        m[9] = c1 * m8 + c2 * m9 + c3 * m10;
        
        c1 = m[2];
        c2 = m[6];
        c3 = m[10];
        m[2] = c1 * m0 + c2 * m1 + c3 * m2;
        m[6] = c1 * m4 + c2 * m5 + c3 * m6;
        m[10] = c1 * m8 + c2 * m9 + c3 * m10;
        
        c1 = m[3];
        c2 = m[7];
        c3 = m[11];
        m[3] = c1 * m0 + c2 * m1 + c3 * m2;
        m[7] = c1 * m4 + c2 * m5 + c3 * m6;
        m[11] = c1 * m8 + c2 * m9 + c3 * m10;
    }
}

void GLIMatrixScaleMatrix(float* m, float xScale, float yScale, float zScale) {
    // [ x 0 0 0 ]   [ 0 4  8 12 ]
    // [ 0 y 0 0 ] x [ 1 5  9 13 ]
    // [ 0 0 z 0 ]   [ 2 6 10 14 ]
    // [ 0 0 0 1 ]   [ 3 7 11 15 ]
    
    m[0] *= xScale;
    m[4] *= xScale;
    m[8] *= xScale;
    m[12] *= xScale;
    
    m[1] *= yScale;
    m[5] *= yScale;
    m[9] *= yScale;
    m[13] *= yScale;
    
    m[2] *= zScale;
    m[6] *= zScale;
    m[10] *= zScale;
    m[14] *= zScale;
}


void GLIMatrixRotateXMatrix(float* m, float rad) {
    // [ 1  0    0  0 ]   [ 0 4  8 12 ]
    // [ 0 cos -sin 0 ] x [ 1 5  9 13 ]
    // [ 0 sin  cos 0 ]   [ 2 6 10 14 ]
    // [ 0  0    0  1 ]   [ 3 7 11 15 ]
    
    float cosrad = cosf(rad);
    float sinrad = sinf(rad);
    
    float m01 = m[1];
    float m05 = m[5];
    float m09 = m[9];
    float m13 = m[13];
    
    m[1] = cosrad * m01 - sinrad * m[2];
    m[2] = sinrad * m01 + cosrad * m[2];
    
    m[5] = cosrad * m05 - sinrad * m[6];
    m[6] = sinrad * m05 + cosrad * m[6];
    
    m[9] = cosrad * m09 - sinrad * m[10];
    m[10] = sinrad * m09 + cosrad * m[10];
    
    m[13] = cosrad * m13 - sinrad * m[14];
    m[14] = sinrad * m13 + cosrad * m[14];
}


void GLIMatrixRotateYMatrix(float* m, float rad) {
    // [ cos 0  -sin 0 ]   [ 0 4  8 12 ]
    // [ 0   1  0    0 ] x [ 1 5  9 13 ]
    // [ sin 0  cos  0 ]   [ 2 6 10 14 ]
    // [ 0   0  0    1 ]   [ 3 7 11 15 ]
    
    float cosrad = cosf(rad);
    float sinrad = sinf(rad);
    
    float m00 = m[0];
    float m04 = m[4];
    float m08 = m[8];
    float m12 = m[12];
    
    m[0] = cosrad * m00 - sinrad * m[2];
    m[2] = sinrad * m00 + cosrad * m[2];
    
    m[4] = cosrad * m04 - sinrad * m[6];
    m[6] = sinrad * m04 + cosrad * m[6];
    
    m[8] = cosrad * m08 - sinrad * m[10];
    m[10] = sinrad * m08 + cosrad * m[10];
    
    m[12] = cosrad * m12 - sinrad * m[14];
    m[14] = sinrad * m12 + cosrad * m[14];
}


void GLIMatrixRotateZMatrix(float* m, float rad) {
    // [ cos -sin 0  0 ]   [ 0 4  8 12 ]
    // [ sin cos  0  0 ] x [ 1 5  9 13 ]
    // [ 0   0    1  0 ]   [ 2 6 10 14 ]
    // [ 0   0    0  1 ]   [ 3 7 11 15 ]
    
    float cosrad = cosf(rad);
    float sinrad = sinf(rad);
    
    float m00 = m[0];
    float m04 = m[4];
    float m08 = m[8];
    float m12 = m[12];
    
    m[0] = cosrad * m00 - sinrad * m[1];
    m[1] = sinrad * m00 + cosrad * m[1];
    
    m[4] = cosrad * m04 - sinrad * m[5];
    m[5] = sinrad * m04 + cosrad * m[5];
    
    m[8] = cosrad * m08 - sinrad * m[9];
    m[9] = sinrad * m08 + cosrad * m[9];
    
    m[12] = cosrad * m12 - sinrad * m[13];
    m[13] = sinrad * m12 + cosrad * m[13];
}

void GLIMatrixRotateMatrix(float* m, float rad, float xAxis, float yAxis, float zAxis) {
    float rotMtx[16];
    
    GLIMatrixLoadRotate(rotMtx, rad, xAxis, yAxis, zAxis);
    
    GLIMatrixMultiply(m, rotMtx, m);
}


void GLIMatrix3x3LoadIdentity(float* m) {
    m[0] = m[4] = m[8] = 1.0f;
    m[1] = m[2] = m[3] = m[5] = m[6] = m[7] = 0.0f;
}

void GLIMatrix3x3LoadDiagonal(float *m, float *vec3)
{
    m[0] = vec3[0];
    m[4] = vec3[1];
    m[8] = vec3[2];
    m[1] = m[2] = m[3] = m[5] = m[6] = m[7] = 0.0f;
}

void GLIMatrix3x3FromTopLeftOf4x4(float* m, const float* src) {
    m[0] = src[0];
    m[1] = src[1];
    m[2] = src[2];
    m[3] = src[4];
    m[4] = src[5];
    m[5] = src[6];
    m[6] = src[8];
    m[7] = src[9];
    m[8] = src[10];
}

void GLIMatrix3x3Transpose(float* m, const float* src) {
    float tmp;
    m[0] = src[0];
    m[4] = src[4];
    m[8] = src[8];
    
    tmp = src[1];
    m[1] = src[3];
    m[3] = tmp;
    
    tmp = src[2];
    m[2] = src[6];
    m[6] = tmp;
    
    tmp = src[5];
    m[5] = src[7];
    m[7] = tmp;
}


void GLIMatrix3x3Invert(float* m, const float* src) {
    float cpy[9];
    float det =
    src[0] * (src[4] * src[8] - src[7] * src[5]) -
    src[1] * (src[3] * src[8] - src[6] * src[5]) +
    src[2] * (src[3] * src[7] - src[6] * src[4]);
    
    if (fabs(det) < 0.0005) {
        GLIMatrix3x3LoadIdentity(m);
        return;
    }
    
    memcpy(cpy, src, 9 * sizeof(float));
    
    m[0] = cpy[4] * cpy[8] - cpy[5] * cpy[7] / det;
    m[1] = -(cpy[1] * cpy[8] - cpy[7] * cpy[2]) / det;
    m[2] = cpy[1] * cpy[5] - cpy[4] * cpy[2] / det;
    
    m[3] = -(cpy[3] * cpy[8] - cpy[5] * cpy[6]) / det;
    m[4] = cpy[0] * cpy[8] - cpy[6] * cpy[2] / det;
    m[5] = -(cpy[0] * cpy[5] - cpy[3] * cpy[2]) / det;
    
    m[6] = cpy[3] * cpy[7] - cpy[6] * cpy[4] / det;
    m[7] = -(cpy[0] * cpy[7] - cpy[6] * cpy[1]) / det;
    m[8] = cpy[0] * cpy[4] - cpy[1] * cpy[3] / det;
}

void GLIMatrix3x3Multiply(float* m, const float* lhs, const float* rhs) {
    m[0] = lhs[0] * rhs[0] + lhs[3] * rhs[1] + lhs[6] * rhs[2];
    m[1] = lhs[1] * rhs[0] + lhs[4] * rhs[1] + lhs[7] * rhs[2];
    m[2] = lhs[2] * rhs[0] + lhs[5] * rhs[1] + lhs[8] * rhs[2];
    
    m[3] = lhs[0] * rhs[3] + lhs[3] * rhs[4] + lhs[6] * rhs[5];
    m[4] = lhs[1] * rhs[3] + lhs[4] * rhs[4] + lhs[7] * rhs[5];
    m[5] = lhs[2] * rhs[3] + lhs[5] * rhs[4] + lhs[8] * rhs[5];
    
    m[6] = lhs[0] * rhs[6] + lhs[3] * rhs[7] + lhs[6] * rhs[8];
    m[7] = lhs[1] * rhs[6] + lhs[4] * rhs[7] + lhs[7] * rhs[8];
    m[8] = lhs[2] * rhs[6] + lhs[5] * rhs[7] + lhs[8] * rhs[8];
}

void GLIMatrixLookAt(float* m, const float* eye_pos, const float* look_dir, const float* up_dir) {
    float r2[3];
    GLIVector3Normalize(r2, look_dir);
    float r0[3];
    GLIVector3CrossProduct(r0, up_dir, r2);
    GLIVector3Normalize(r0, r0);
    float r1[3];
    GLIVector3CrossProduct(r1, r2, r0);
    m[0] = r0[0];
    m[4] = r0[1];
    m[8] = r0[2];
    m[12] = -1 * eye_pos[0];
    
    m[1] = r1[0];
    m[5] = r1[1];
    m[9] = r1[2];
    m[13] = -1 * eye_pos[1];
    
    m[2] = r2[0];
    m[6] = r2[1];
    m[10] = r2[2];
    m[14] = -1 * eye_pos[2];
    
    m[3] = 0.f;
    m[7] = 0.f;
    m[11] = 0.f;
    m[15] = 1.f;
}

void GLITransformVector4(float* vec4, const float* mat4x4, const float* ori_vec4) {
    for (int i = 0; i < 4; ++i) {
        vec4[i] = 0;
        for (int j = 0; j < 4; ++j) {
            vec4[i] += mat4x4[i + 4 * j] * ori_vec4[j];
        }
    }
}
