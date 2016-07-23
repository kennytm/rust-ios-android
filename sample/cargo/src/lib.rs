extern crate regex;
extern crate jni_sys;

use regex::Regex;

use std::os::raw::{c_char, c_int};
use std::ffi::CStr;
use std::ptr::null_mut;

/// Constructs a regular expression object. Returns NULL if the pattern is invalid.
#[no_mangle]
pub extern "C" fn rust_regex_create(pattern: *const c_char) -> *mut Regex {
    if pattern.is_null() {
        return null_mut();
    }

    let c_str = unsafe { CStr::from_ptr(pattern) };
    let string = match c_str.to_str() {
        Err(_) => return null_mut(),
        Ok(string) => string,
    };
    let regex = match Regex::new(string) {
        Err(_) => return null_mut(),
        Ok(regex) => Box::new(regex),
    };

    Box::into_raw(regex)
}


/// Destroys a regular expression object previously constructed using `rust_regex_create()`.
#[no_mangle]
pub unsafe extern "C" fn rust_regex_destroy(regex: *mut Regex) {
    drop(Box::from_raw(regex))
}


/// Finds the first index where the regex matches the text. Returns -1 if no match, and a negative
/// number on error.
#[no_mangle]
pub extern "C" fn rust_regex_find(regex: *const Regex, text: *const c_char) -> c_int {
    let regex = match unsafe { regex.as_ref() } {
        None => return -2,
        Some(regex) => regex,
    };

    if text.is_null() {
        return -4;
    }

    let c_str = unsafe { CStr::from_ptr(text) };
    let text = match c_str.to_str() {
        Err(_) => return -3,
        Ok(text) => text,
    };

    match regex.find(text) {
        None => -1,
        Some((start, _)) => start as c_int,
    }
}


/// Expose the JNI interface for android below
#[cfg(target_os="android")]
#[allow(non_snake_case)]
pub mod android {
    use super::*;
    use jni_sys::*;
    use regex::Regex;
    use std::ptr::null_mut;

    #[no_mangle]
    pub unsafe extern "C" fn Java_kennytm_rustsample_RustSampleActivity_regexCreate(env: *mut JNIEnv, _: jclass, java_pattern: jstring) -> jlong {
        let ref java = **env;
        let pattern = (java.GetStringUTFChars)(env, java_pattern, null_mut());
        let regex = rust_regex_create(pattern);
        (java.ReleaseStringUTFChars)(env, java_pattern, pattern);
        regex as jlong
    }

    #[no_mangle]
    pub unsafe extern "C" fn Java_kennytm_rustsample_RustSampleActivity_regexFind(env: *mut JNIEnv, _: jclass, regex_ptr: jlong, java_text: jstring) -> jint {
        let ref java = **env;
        let text = (java.GetStringUTFChars)(env, java_text, null_mut());
        let res = rust_regex_find(regex_ptr as *const Regex, text);
        (java.ReleaseStringUTFChars)(env, java_text, text);
        res
    }

    #[no_mangle]
    pub unsafe extern "C" fn Java_kennytm_rustsample_RustSampleActivity_regexDestroy(_: *mut JNIEnv, _: jclass, regex_ptr: jlong) {
        let regex = regex_ptr as *mut Regex;
        rust_regex_destroy(regex)
    }
}



#[cfg(test)]
mod tests {
    use {rust_regex_create, rust_regex_destroy, rust_regex_find};
    use std::ffi::CString;

    #[test]
    fn test_create_destroy() {
        let input = CString::new("abc").unwrap();
        let rx = rust_regex_create(input.as_ptr());
        assert!(!rx.is_null());
        unsafe { rust_regex_destroy(rx) };
    }

    #[test]
    fn test_find() {
        let input = CString::new("a..").unwrap();
        let rx = rust_regex_create(input.as_ptr());

        let test1 = CString::new("oooabcd").unwrap();
        assert_eq!(3, rust_regex_find(rx, test1.as_ptr()));

        let test2 = CString::new("paappq").unwrap();
        assert_eq!(1, rust_regex_find(rx, test2.as_ptr()));

        let test3 = CString::new("zzae").unwrap();
        assert_eq!(-1, rust_regex_find(rx, test3.as_ptr()));

        unsafe { rust_regex_destroy(rx) };
    }
}


