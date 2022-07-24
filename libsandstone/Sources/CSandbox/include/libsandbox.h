//
//  libsandbox.h
//  libsandstone
//
//  Created by Spotlight Deveaux on 2022-07-24.
//

#ifndef libsandbox_h
#define libsandbox_h

#import <sys/types.h>

struct sandbox_profile {
    unsigned int type;
    void* bytecode;
    size_t bytecode_length;
};

struct sandbox_profile* sandbox_compile_string(const char* profile_sbpl, void* parameters, char** error);
void sandbox_free_profile(struct sandbox_profile* profile);

#endif /* libsandbox_h */
