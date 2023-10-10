// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "messages.g.h"

struct _MyMessageData {
  GObject parent_instance;

  const gchar* name;
  const gchar* description;
  MyCode code;
  FlValue* data;
};

G_DEFINE_TYPE(MyMessageData, my_message_data, G_TYPE_OBJECT)

static void my_message_data_dispose(GObject* object) {
  MyMessageData* self = MY_MESSAGE_DATA(object);

  G_OBJECT_CLASS(my_message_data_parent_class)->dispose(object);
}

static void my_message_data_init(MyMessageData* self) {}

static void my_message_data_class_init(MyMessageDataClass* klass) {}

MyMessageData* my_message_data_new(MyCode code, FlValue* data) {
  MyMessageData* self = g_object_new(my_message_data_get_type(), nullptr);
  self->code = code;
  self->data = g_object_ref(data);
  return self;
}

MyMessageData* my_message_data_new_full(const gchar* name,
                                        const gchar* description, MyCode code,
                                        FlValue* data) {
  MyMessageData* self = g_object_new(my_message_data_get_type(), nullptr);
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
  g_return_val_if_fail(MY_IS_MESSAGE_DATA(object), 0);
  return object->code;
}

FlValue* my_message_data_get_data(MyMessageData* object) {
  g_return_val_if_fail(MY_IS_MESSAGE_DATA(object), nullptr);
  return object->data;
}

struct _MyMessageFlutterApi {
  GObject parent_instance;
};

G_DEFINE_TYPE(MyMessageFlutterApi, my_message_flutter_api, G_TYPE_OBJECT)

MyMessageFlutterApi* my_message_flutter_api_new() {
  return g_object_new(my_message_flutter_api_new(), nullptr);
}

void my_message_flutter_api_flutter_method_async(MyMessageFlutterApi* object,
                                                 const gchar* a_string,
                                                 GCancellable* cancellable,
                                                 GAsyncReadyCallback callback,
                                                 gpointer user_data) {}

gboolean my_message_flutter_api_flutter_method_finish(
    MyMessageFlutterApi* object, GAsyncResult* result, gchar** result,
    GError** error) {
  return TRUE;
}
