// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "messages.g.h"

struct _MyMessageData {
  GObject parent_instance;

  gchar* name;
  gchar* description;
  MyCode code;
  FlValue* data;
};

G_DEFINE_TYPE(MyMessageData, my_message_data, G_TYPE_OBJECT)

static void my_message_data_dispose(GObject* object) {
  MyMessageData* self = MY_MESSAGE_DATA(object);
  g_clear_pointer(&self->name, g_free);
  g_clear_pointer(&self->description, g_free);
  g_clear_object(&self->data);
  G_OBJECT_CLASS(my_message_data_parent_class)->dispose(object);
}

static void my_message_data_init(MyMessageData* self) {}

static void my_message_data_class_init(MyMessageDataClass* klass) {
  GObjectClass* object_class = G_OBJECT_CLASS(klass);
  object_class->dispose = my_message_data_dispose;
}

MyMessageData* my_message_data_new(MyCode code, FlValue* data) {
  MyMessageData* self =
      MY_MESSAGE_DATA(g_object_new(my_message_data_get_type(), nullptr));
  self->code = code;
  self->data = g_object_ref(data);
  return self;
}

MyMessageData* my_message_data_new_full(const gchar* name,
                                        const gchar* description, MyCode code,
                                        FlValue* data) {
  MyMessageData* self =
      MY_MESSAGE_DATA(g_object_new(my_message_data_get_type(), nullptr));
  self->name = g_strdup(name);
  self->description = g_strdup(description);
  self->code = code;
  self->data = g_object_ref(data);
  return self;
}

const gchar* my_message_data_get_name(MyMessageData* object) {
  g_return_val_if_fail(MY_IS_MESSAGE_DATA(object), nullptr);
  return object->name;
}

const gchar* my_message_data_get_description(MyMessageData* object) {
  g_return_val_if_fail(MY_IS_MESSAGE_DATA(object), nullptr);
  return object->description;
}

MyCode my_message_data_get_code(MyMessageData* object) {
  g_return_val_if_fail(MY_IS_MESSAGE_DATA(object), static_cast<MyCode>(0));
  return object->code;
}

FlValue* my_message_data_get_data(MyMessageData* object) {
  g_return_val_if_fail(MY_IS_MESSAGE_DATA(object), nullptr);
  return object->data;
}

struct _MyExampleHostApi {
  GObject parent_instance;

  FlBinaryMessenger* messenger;
};

G_DEFINE_TYPE(MyExampleHostApi, my_example_host_api, G_TYPE_OBJECT)

static void my_example_host_api_dispose(GObject* object) {
  MyExampleHostApi* self = MY_EXAMPLE_HOST_API(object);
  g_clear_object(&self->messenger);
  G_OBJECT_CLASS(my_example_host_api_parent_class)->dispose(object);
}

static void my_example_host_api_init(MyExampleHostApi* self) {}

static void my_example_host_api_class_init(MyExampleHostApiClass* klass) {
  GObjectClass* object_class = G_OBJECT_CLASS(klass);
  object_class->dispose = my_example_host_api_dispose;
}

MyExampleHostApi* my_example_host_api_new(FlBinaryMessenger* messenger,
                                          const MyExampleHostApiVTable vtable,
                                          gpointer user_data,
                                          GDestroyNotify user_data_free_func) {
  MyExampleHostApi* self = MY_EXAMPLE_HOST_API(
      g_object_new(my_example_host_api_get_type(), nullptr));
  self->messenger = g_object_ref(messenger);
  return self;
}

void my_example_host_api_respond_get_host_language(MyExampleHostApi* object,
                                                   FlMethodCall* method_call,
                                                   const gchar* result) {}

void my_example_host_api_respond_add(MyExampleHostApi* object,
                                     FlMethodCall* method_call,
                                     int64_t result) {}

void my_example_host_api_respond_send_message(MyExampleHostApi* object,
                                              FlMethodCall* method_call,
                                              gboolean result) {}

struct _MyMessageFlutterApi {
  GObject parent_instance;

  FlBinaryMessenger* messenger;
};

G_DEFINE_TYPE(MyMessageFlutterApi, my_message_flutter_api, G_TYPE_OBJECT)

static void my_message_flutter_api_dispose(GObject* object) {
  MyMessageFlutterApi* self = MY_MESSAGE_FLUTTER_API(object);
  g_clear_object(&self->messenger);
  G_OBJECT_CLASS(my_message_flutter_api_parent_class)->dispose(object);
}

static void my_message_flutter_api_init(MyMessageFlutterApi* self) {}

static void my_message_flutter_api_class_init(MyMessageFlutterApiClass* klass) {
  GObjectClass* object_class = G_OBJECT_CLASS(klass);
  object_class->dispose = my_message_flutter_api_dispose;
}

MyMessageFlutterApi* my_message_flutter_api_new(FlBinaryMessenger* messenger) {
  MyMessageFlutterApi* self = MY_MESSAGE_FLUTTER_API(
      g_object_new(my_message_flutter_api_get_type(), nullptr));
  self->messenger = g_object_ref(messenger);
  return self;
}

void my_message_flutter_api_flutter_method_async(MyMessageFlutterApi* object,
                                                 const gchar* a_string,
                                                 GCancellable* cancellable,
                                                 GAsyncReadyCallback callback,
                                                 gpointer user_data) {}

gboolean my_message_flutter_api_flutter_method_finish(
    MyMessageFlutterApi* object, GAsyncResult* result, gchar** value,
    GError** error) {
  return TRUE;
}
