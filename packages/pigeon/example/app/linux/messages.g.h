// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v11.0.1), do not edit directly.
// See also: https://pub.dev/packages/pigeon

#ifndef PIGEON_MESSAGES_G_H_
#define PIGEON_MESSAGES_G_H_

#include <flutter_linux/flutter_linux.h>

G_BEGIN_DECLS

G_DECLARE_FINAL_TYPE(MyMessageData, my_message_data, MY, MESSAGE_DATA, GObject)

typedef enum { MY_CODE_ONE = 0, MY_CODE_TWO = 1 } MyCode;

MyMessageData* my_message_data_new(MyCode code, FlValue* data);

MyMessageData* my_message_data_new_full(const gchar* name,
                                        const gchar* description, MyCode code,
                                        FlValue* data);

const gchar* my_message_data_get_name(MyMessageData* object);

const gchar* my_message_data_get_description(MyMessageData* object);

MyCode my_message_data_get_code(MyMessageData* object);

FlValue* my_message_data_get_data(MyMessageData* object);

G_DECLARE_DERIVABLE_TYPE(MyExampleHostApi, my_example_host_api, MY,
                         EXAMPLE_HOST_API, GObject)

struct _MyExampleHostApiClass {
  GObjectClass parent_class;

  void (*get_host_language)(MyExampleHostApi* object,
                            FlMethodCall* method_call);
  void (*add)(MyExampleHostApi* object, FlMethodCall* method_call, int64_t a,
              int64_t b);
  void (*send_message)(MyExampleHostApi* object, FlMethodCall* method_call,
                       MyMessageData* message);
};

void my_example_host_api_respond_get_host_language(MyExampleHostApi* object,
                                                   FlMethodCall* method_call,
                                                   const gchar* result);

void my_example_host_api_respond_add(MyExampleHostApi* object,
                                     FlMethodCall* method_call, int64_t result);

void my_example_host_api_respond_send_message(MyExampleHostApi* object,
                                              FlMethodCall* method_call,
                                              gboolean result);

G_DECLARE_FINAL_TYPE(MyMessageFlutterApi, my_message_flutter_api, MY,
                     MESSAGE_FLUTTER_API, GObject)

MyMessageFlutterApi* my_message_flutter_api_new();

void my_message_flutter_api_flutter_method_async(MyMessageFlutterApi* object,
                                                 const gchar* a_string,
                                                 GCancellable* cancellable,
                                                 GAsyncReadyCallback callback,
                                                 gpointer user_data);

gboolean my_message_flutter_api_flutter_method_finish(
    MyMessageFlutterApi* object, GAsyncResult* result, gchar** value,
    GError** error);

#endif  // PIGEON_MESSAGES_G_H_
