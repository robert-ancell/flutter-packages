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

struct _MyExampleHostApiGetHostLanguageResponse {
  GObject parent_instance;

  FlValue* value;
};

G_DEFINE_TYPE(MyExampleHostApiGetHostLanguageResponse,
              my_example_host_api_get_host_language_response, G_TYPE_OBJECT)

static void my_example_host_api_get_host_language_dispose(GObject* object) {
  MyExampleHostApiGetHostLanguageResponse* self =
      MY_EXAMPLE_HOST_API_GET_HOST_LANGUAGE_RESPONSE(object);
  g_clear_object(&self->value);
  G_OBJECT_CLASS(my_example_host_api_get_host_language_response_parent_class)
      ->dispose(object);
}

static void my_example_host_api_get_host_language_response_init(
    MyExampleHostApiGetHostLanguageResponse* self) {}

static void my_example_host_api_get_host_language_response_class_init(
    MyExampleHostApiGetHostLanguageResponseClass* klass) {
  GObjectClass* object_class = G_OBJECT_CLASS(klass);
  object_class->dispose = my_example_host_api_get_host_language_dispose;
}

MyExampleHostApiGetHostLanguageResponse*
my_example_host_api_get_host_language_response_new(const gchar* value) {
  MyExampleHostApiGetHostLanguageResponse* self =
      MY_EXAMPLE_HOST_API_GET_HOST_LANGUAGE_RESPONSE(g_object_new(
          my_example_host_api_get_host_language_response_get_type(), nullptr));
  self->value = fl_value_new_list();
  fl_value_append_take(self->value, fl_value_new_string(value));
  return self;
}

MyExampleHostApiGetHostLanguageResponse*
my_example_host_api_get_host_language_response_new_error(const gchar* code,
                                                         const gchar* message,
                                                         FlValue* details) {
  MyExampleHostApiGetHostLanguageResponse* self =
      MY_EXAMPLE_HOST_API_GET_HOST_LANGUAGE_RESPONSE(g_object_new(
          my_example_host_api_get_host_language_response_get_type(), nullptr));
  self->value = fl_value_new_list();
  fl_value_append_take(self->value, fl_value_new_string(code));
  fl_value_append_take(self->value, fl_value_new_string(message));
  fl_value_append(self->value, details);
  return self;
}

struct _MyExampleHostApiAddResponse {
  GObject parent_instance;

  FlValue* value;
};

G_DEFINE_TYPE(MyExampleHostApiAddResponse, my_example_host_api_add_response,
              G_TYPE_OBJECT)

static void my_example_host_api_add_response_dispose(GObject* object) {
  MyExampleHostApiAddResponse* self = MY_EXAMPLE_HOST_API_ADD_RESPONSE(object);
  g_clear_object(&self->value);
  G_OBJECT_CLASS(my_example_host_api_add_response_parent_class)
      ->dispose(object);
}

static void my_example_host_api_add_response_init(
    MyExampleHostApiAddResponse* self) {}

static void my_example_host_api_add_response_class_init(
    MyExampleHostApiAddResponseClass* klass) {
  GObjectClass* object_class = G_OBJECT_CLASS(klass);
  object_class->dispose = my_example_host_api_add_response_dispose;
}

MyExampleHostApiAddResponse* my_example_host_api_add_response_new(
    int64_t value) {
  MyExampleHostApiAddResponse* self = MY_EXAMPLE_HOST_API_ADD_RESPONSE(
      g_object_new(my_example_host_api_add_response_get_type(), nullptr));
  self->value = fl_value_new_list();
  fl_value_append_take(self->value, fl_value_new_int(value));
  return self;
}

MyExampleHostApiAddResponse* my_example_host_api_add_response_new_error(
    const gchar* code, const gchar* message, FlValue* details) {
  MyExampleHostApiAddResponse* self = MY_EXAMPLE_HOST_API_ADD_RESPONSE(
      g_object_new(my_example_host_api_add_response_get_type(), nullptr));
  self->value = fl_value_new_list();
  fl_value_append_take(self->value, fl_value_new_string(code));
  fl_value_append_take(self->value, fl_value_new_string(message));
  fl_value_append(self->value, details);
  return self;
}

struct _MyExampleHostApiSendMessageResponseHandle {
  GObject parent_instance;

  FlBasicMessageChannel* channel;
  FlBasicMessageChannelResponseHandle* response_handle;
};

G_DEFINE_TYPE(MyExampleHostApiSendMessageResponseHandle,
              my_example_host_api_send_message_response_handle, G_TYPE_OBJECT)

static void my_example_host_api_send_message_response_handle_dispose(
    GObject* object) {
  MyExampleHostApiSendMessageResponseHandle* self =
      MY_EXAMPLE_HOST_API_SEND_MESSAGE_RESPONSE_HANDLE(object);
  g_clear_object(&self->channel);
  g_clear_object(&self->response_handle);
  G_OBJECT_CLASS(my_example_host_api_send_message_response_handle_parent_class)
      ->dispose(object);
}

static void my_example_host_api_send_message_response_handle_init(
    MyExampleHostApiSendMessageResponseHandle* self) {}

static void my_example_host_api_send_message_response_handle_class_init(
    MyExampleHostApiSendMessageResponseHandleClass* klass) {
  GObjectClass* object_class = G_OBJECT_CLASS(klass);
  object_class->dispose =
      my_example_host_api_send_message_response_handle_dispose;
}

MyExampleHostApiSendMessageResponseHandle*
my_example_host_api_send_message_response_handle_new(
    FlBasicMessageChannel* channel,
    FlBasicMessageChannelResponseHandle* response_handle) {
  MyExampleHostApiSendMessageResponseHandle* self =
      MY_EXAMPLE_HOST_API_SEND_MESSAGE_RESPONSE_HANDLE(g_object_new(
          my_example_host_api_send_message_response_handle_get_type(),
          nullptr));
  self->channel = g_object_ref(channel);
  self->response_handle = g_object_ref(response_handle);
  return self;
}

void my_example_host_api_send_message_response_handle_respond(
    MyExampleHostApiSendMessageResponseHandle* self, gboolean result) {
  g_autoptr(FlValue) value = fl_value_new_list();
  fl_value_append_take(value, fl_value_new_bool(result));

  g_autoptr(GError) error = NULL;
  if (!fl_basic_message_channel_respond(self->channel, self->response_handle,
                                        value, &error)) {
    g_warning("Failed to send response to SendMessage: %s\n", error->message);
  }
}

void my_example_host_api_send_message_response_handle_respond_error(
    MyExampleHostApiSendMessageResponseHandle* self, const gchar* code,
    const gchar* message, FlValue* details) {
  g_autoptr(FlValue) value = fl_value_new_list();
  fl_value_append_take(value, fl_value_new_string(code));
  fl_value_append_take(value, fl_value_new_string(message));
  fl_value_append(value, details);

  g_autoptr(GError) error = NULL;
  if (!fl_basic_message_channel_respond(self->channel, self->response_handle,
                                        value, &error)) {
    g_warning("Failed to send response to SendMessage: %s\n", error->message);
  }
}

struct _MyExampleHostApi {
  GObject parent_instance;

  FlBinaryMessenger* messenger;
  const MyExampleHostApiVTable* vtable;
  gpointer user_data;
  GDestroyNotify user_data_free_func;

  FlBasicMessageChannel* get_host_language_channel;
  FlBasicMessageChannel* add_channel;
  FlBasicMessageChannel* send_message_channel;
};

G_DEFINE_TYPE(MyExampleHostApi, my_example_host_api, G_TYPE_OBJECT)

static void get_host_language_cb(
    FlBasicMessageChannel* channel, FlValue* message,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  MyExampleHostApi* self = MY_EXAMPLE_HOST_API(user_data);
  if (self->vtable->get_host_language == nullptr) {
    return;
  }

  g_autoptr(MyExampleHostApiGetHostLanguageResponse) response =
      self->vtable->get_host_language(self, self->user_data);
  if (response == nullptr) {
    g_warning("No response returned to GetHostLanguage");
    return;
  }

  g_autoptr(GError) error = NULL;
  if (!fl_basic_message_channel_respond(channel, response_handle,
                                        response->value, &error)) {
    g_warning("Failed to send response to GetHostLanguage: %s\n",
              error->message);
  }
}

static void add_cb(FlBasicMessageChannel* channel, FlValue* message,
                   FlBasicMessageChannelResponseHandle* response_handle,
                   gpointer user_data) {
  MyExampleHostApi* self = MY_EXAMPLE_HOST_API(user_data);
  int64_t a = 0, b = 0;
  if (self->vtable->add == nullptr) {
    return;
  }

  g_autoptr(MyExampleHostApiAddResponse) response =
      self->vtable->add(self, a, b, self->user_data);
  if (response == nullptr) {
    g_warning("No response returned to Add");
    return;
  }

  g_autoptr(GError) error = NULL;
  if (!fl_basic_message_channel_respond(channel, response_handle,
                                        response->value, &error)) {
    g_warning("Failed to send response to Add: %s\n", error->message);
  }
}

static void send_message_cb(
    FlBasicMessageChannel* channel, FlValue* message,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  MyExampleHostApi* self = MY_EXAMPLE_HOST_API(user_data);
  g_autoptr(FlValue) data = fl_value_new_null();
  g_autoptr(MyMessageData) message_data =
      my_message_data_new(MY_CODE_ONE, data);
  if (self->vtable->send_message != nullptr) {
    g_autoptr(MyExampleHostApiSendMessageResponseHandle) handle =
        my_example_host_api_send_message_response_handle_new(channel,
                                                             response_handle);
    self->vtable->send_message(self, handle, message_data, self->user_data);
  }
}

static void my_example_host_api_dispose(GObject* object) {
  MyExampleHostApi* self = MY_EXAMPLE_HOST_API(object);
  g_clear_object(&self->messenger);
  if (self->user_data != nullptr) {
    self->user_data_free_func(self->user_data);
  }
  self->user_data = nullptr;
  g_clear_object(&self->get_host_language_channel);
  g_clear_object(&self->add_channel);
  g_clear_object(&self->send_message_channel);
  G_OBJECT_CLASS(my_example_host_api_parent_class)->dispose(object);
}

static void my_example_host_api_init(MyExampleHostApi* self) {}

static void my_example_host_api_class_init(MyExampleHostApiClass* klass) {
  GObjectClass* object_class = G_OBJECT_CLASS(klass);
  object_class->dispose = my_example_host_api_dispose;
}

MyExampleHostApi* my_example_host_api_new(FlBinaryMessenger* messenger,
                                          const MyExampleHostApiVTable* vtable,
                                          gpointer user_data,
                                          GDestroyNotify user_data_free_func) {
  MyExampleHostApi* self = MY_EXAMPLE_HOST_API(
      g_object_new(my_example_host_api_get_type(), nullptr));
  self->messenger = g_object_ref(messenger);
  self->user_data = user_data;
  self->user_data_free_func = user_data_free_func;

  g_autoptr(FlStandardMessageCodec) codec = fl_standard_message_codec_new();
  self->get_host_language_channel =
      fl_basic_message_channel_new(messenger,
                                   "dev.flutter.pigeon.pigeon_example_package."
                                   "ExampleHostApi.getHostLanguage",
                                   FL_MESSAGE_CODEC(codec));
  fl_basic_message_channel_set_message_handler(
      self->get_host_language_channel, get_host_language_cb, self, nullptr);
  self->add_channel = fl_basic_message_channel_new(
      messenger, "dev.flutter.pigeon.pigeon_example_package.ExampleHostApi.add",
      FL_MESSAGE_CODEC(codec));
  fl_basic_message_channel_set_message_handler(self->add_channel, add_cb, self,
                                               nullptr);
  self->send_message_channel = fl_basic_message_channel_new(
      messenger,
      "dev.flutter.pigeon.pigeon_example_package.ExampleHostApi.sendMessage",
      FL_MESSAGE_CODEC(codec));
  fl_basic_message_channel_set_message_handler(self->send_message_channel,
                                               send_message_cb, self, nullptr);

  return self;
}

gboolean my_example_host_api_respond_send_message(
    MyExampleHostApi* self,
    FlBasicMessageChannelResponseHandle* response_handle, gboolean result,
    GError** error) {
  g_autoptr(FlValue) message = fl_value_new_list();
  fl_value_append_take(message, fl_value_new_bool(result));
  return fl_basic_message_channel_respond(self->send_message_channel,
                                          response_handle, message, error);
}

gboolean my_example_host_api_respond_error_send_message(
    MyExampleHostApi* self,
    FlBasicMessageChannelResponseHandle* response_handle, const gchar* code,
    const gchar* message_, FlValue* details, GError** error) {
  g_autoptr(FlValue) message = fl_value_new_list();
  fl_value_append_take(message, fl_value_new_string(code));
  fl_value_append_take(message, fl_value_new_string(message_));
  fl_value_append(message, details);
  return fl_basic_message_channel_respond(self->send_message_channel,
                                          response_handle, message, error);
}

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
