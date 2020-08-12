/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Functions for performing matrix math.
*/

#ifndef GLIMatrixUtil_h
#define GLIMatrixUtil_h

#include <QuartzCore/QuartzCore.h>

#ifdef __cplusplus
extern "C" {
#endif
    
// Matrix is a column major floating point array

// All matrices are 4x4 by unless the m3x3 prefix is specified in the function name

// [ 0 4  8 12 ]
// [ 1 5  9 13 ]
// [ 2 6 10 14 ]
// [ 3 7 11 15 ]

#define GLIMatrixFromColumns(...)        { __VA_ARGS__ }
#define GLIMatrix3x3FromColumns(...)     { __VA_ARGS__ }

void GLIMatrixLoadFromColumns(float *m, float c00, float c10, float c20, float c30,
                                      float c01, float c11, float c21, float c31,
                                      float c02, float c12, float c22, float c32,
                                      float c03, float c13, float c23, float c33);

void GLIMatrix3x3LoadFromColumns(float *m, float c00, float c10, float c20,
                                         float c01, float c11, float c21,
                                         float c02, float c12, float c22);

void GLIMatrixLoadFromRows(float *m, float r00, float r01, float r02, float r03,
                                      float r10, float r11, float r12, float r13,
                                      float r20, float r21, float r22, float r23,
                                      float r30, float r31, float r32, float r33);

void GLIMatrix3x3LoadFromRows(float *m, float r00, float r01, float r02,
                                          float r10, float r11, float r12,
                                          float r20, float r21, float r22);

void GLIMatrixLinearCombination(float *m, float a, const float *lhs, float b, const float *rhs);
void GLIMatrix3x3LinearCombination(float *m, float a, const float *lhs, float b, const float *rhs);

// MTX = LeftHandSideMatrix * RightHandSideMatrix
void GLIMatrixMultiply(float* ret, const float* lhs, const float* rhs);

// MTX = IdentityMatrix
void GLIMatrixLoadIdentity(float* m);

void GLIMatrixLoadCATransform3D(float *m, CATransform3D transform);

void GLIMatrixLoadDiagonal(float *m, float *vec4);
    
// MTX = Transpos(SRC)
void GLIMatrixTranspose(float* m, const float* src);

// MTX = src^-1
void GLIMatrixInvert(float* m, const float* src);

// MTX = PerspectiveProjectionMatrix
void GLIMatrixLoadPerspective(float* m, float fov, float aspect, float nearZ, float farZ);

// MTX = OrthographicProjectionMatrix
void GLIMatrixLoadOrthographic(float* m, float left, float right, float bottom, float top, float nearZ, float farZ);
void GLIMatrixLoadOrthographicOffCenter(float* m, float left, float right, float bottom, float top, float nearZ, float farZ);

// MTX = ObliqueProjectionMatrix(src, clipPlane)
void GLIMatrixModifyObliqueProjection(float* m, const float* src, const float* plane);

// MTX = TranlationMatrix
void GLIMatrixLoadTranslate(float* m, float xTrans, float yTrans, float zTrans);

// MTX = ScaleMatrix
void GLIMatrixLoadScale(float* m, float xScale, float yScale, float zScale);

// MTX = RotateXYZMatrix
void GLIMatrixLoadRotate(float* m, float deg, float xAxis, float, float zAxis);

// MTX = RotateXMatrix
void GLIMatrixLoadRotateX(float* m, float deg);

// MTX = RotateYMatrix
void GLIMatrixLoadRotateY(float* m, float deg);

// MTX = RotateZMatrix
void GLIMatrixLoadRotateZ(float* m, float deg);

// MTX = MTX * TranslationMatrix - Similar to glTranslate
void GLIMatrixTranslateApply(float* m, float xTrans, float yTrans, float zTrans);

// MTX = MTX * ScaleMatrix - Similar to glScale
void GLIMatrixScaleApply(float* m, float xScale, float yScale, float zScale);

// MTX = MTX * RotateXYZMatrix - Similar to glRotate
void GLIMatrixRotateApply(float* m, float deg, float xAxis, float yAxis, float zAxis);

// MTX = MTX * RotateXMatrix
void GLIMatrixRotateXApply(float* m, float rad);

// MTX = MTX * RotateYMatrix
void GLIMatrixRotateYApply(float* m, float rad);

// MTX = MTX * RotateZMatrix
void GLIMatrixRotateZApply(float* m, float rad);

// MTX = TranslationMatrix * MTX
void GLIMatrixTranslateMatrix(float* m, float xTrans, float yTrans, float zTrans);

// MTX = ScaleMatrix * MTX
void GLIMatrixScaleMatrix(float* m, float xScale, float yScale, float zScale);

// MTX = RotateXYZMatrix * MTX
void GLIMatrixRotateMatrix(float* m, float rad, float xAxis, float yAxis, float zAxis);

// MTX = RotateXMatrix * MTX
void GLIMatrixRotateXMatrix(float* m, float rad);

// MTX = RotateYMatrix * MTX
void GLIMatrixRotateYMatrix(float* m, float rad);

// MTX = RotateZMatrix * MTX
void GLIMatrixRotateZMatrix(float* m, float rad);

// 3x3 MTX = 3x3 IdendityMatrix
void GLIMatrix3x3LoadIdentity(float* m);

void GLIMatrix3x3LoadDiagonal(float *m, float *vec3);


// 3x3 MTX = 3x3 LHS x 3x3 RHS
void GLIMatrix3x3Multiply(float* m, const float* lhs, const float* rhs);

// 3x3 MTX = TopLeft of MTX
void GLIMatrix3x3FromTopLeftOf4x4(float* m, const float* src);

// 3x3 MTX = Transpose(3x3 SRC)
void GLIMatrix3x3Transpose(float* m, const float* src);

// 3x3 MTX = 3x3 SRC^-1
void GLIMatrix3x3Invert(float* m, const float* src);

void GLIMatrixLookAt(float* m, const float* eye_pos, const float* look_dir, const float* up_dir);

void GLITransformVector4(float* vec4, const float* mat4x4, const float* ori_vec4);
    
#ifdef __cplusplus
}
#endif

#endif /* GLIMatrixUtil_h */
