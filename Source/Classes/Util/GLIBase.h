//
//  GLIBase.h
//  GLInterop
//
//  Created by Qin Hong on 6/4/19.
//

#ifndef GLIBase_h
#define GLIBase_h

#if defined(__APPLE__)
#include <TargetConditionals.h>
#include <Availability.h>
#include <AvailabilityMacros.h>
#include <CoreFoundation/CFBase.h>
#endif

/*
 * INLINE and EXTERN
 */
#if !defined(GLI_INLINE)
#if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 199901L
#define GLI_INLINE static inline
#elif defined(__MWERKS__) || defined(__cplusplus)
#define GLI_INLINE static inline
#elif defined(__GNUC__)
#define GLI_INLINE static __inline__
#elif defined(_MSC_VER)
#define GLI_INLINE static __inline
#else
#define GLI_INLINE static
#endif
#endif

#define GLI_EXPORT __attribute__((visibility ("default")))

#ifdef __cplusplus
#define GLI_EXTERN extern "C" GLI_EXPORT
#else
#define GLI_EXTERN extern GLI_EXPORT
#endif

/*
 * OVERLOADABLE
 */
#if __has_extension(attribute_overloadable)
#define GLI_OVERLOADABLE __attribute__((__overloadable__))
#else
#define GLI_OVERLOADABLE
#endif

#endif /* GLIBase_h */
