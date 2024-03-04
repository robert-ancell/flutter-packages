// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v14.0.1), do not edit directly.
// See also: https://pub.dev/packages/pigeon

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
  g_clear_pointer(&self->data, fl_value_unref);
  G_OBJECT_CLASS(my_message_data_parent_class)->dispose(object);
}

static void my_message_data_init(MyMessageData* self) {}

static void my_message_data_class_init(MyMessageDataClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = my_message_data_dispose;
}

MyMessageData* my_message_data_new(const gchar* name, const gchar* description,
                                   MyCode code, FlValue* data) {
  MyMessageData* self =
      MY_MESSAGE_DATA(g_object_new(my_message_data_get_type(), nullptr));
  self->name = g_strdup(name);
  self->description = g_strdup(description);
  self->code = code;
  self->data = g_object_ref(data);
  return self;
}

const gchar* my_message_data_get_name(MyMessageData* self) {
  g_return_val_if_fail(MY_IS_MESSAGE_DATA(self), nullptr);
  return self->name;
}

const gchar* my_message_data_get_description(MyMessageData* self) {
  g_return_val_if_fail(MY_IS_MESSAGE_DATA(self), nullptr);
  return self->description;
}

MyCode my_message_data_get_code(MyMessageData* self) {
  g_return_val_if_fail(MY_IS_MESSAGE_DATA(self), static_cast<MyCode>(0));
  return self->code;
}

FlValue* my_message_data_get_data(MyMessageData* self) {
  g_return_val_if_fail(MY_IS_MESSAGE_DATA(self), nullptr);
  return self->data;
}

static gboolean my_message_data_write_value(FlStandardMessageCodec* codec,
                                            GByteArray* buffer,
                                            MyMessageData* value,
                                            GError** error) {
  uint8_t type = 128;
  g_byte_array_append(buffer, &type, sizeof(uint8_t));
  g_autoptr(FlValue) values = fl_value_new_list();
  fl_value_append_take(values, fl_value_new_string(value->name));
  fl_value_append_take(values, fl_value_new_string(value->description));
  fl_value_append_take(values, fl_value_new_int(value->code));
  fl_value_append(values, value->data);
  return fl_standard_message_codec_write_value(codec, buffer, values, error);
}

static FlValue* my_message_data_read_value(FlStandardMessageCodec* codec,
                                           GBytes* buffer, size_t* offset,
                                           GError** error) {
  g_autoptr(FlValue) values =
      fl_standard_message_codec_read_value(codec, buffer, offset, error);
  if (values == nullptr) {
    return nullptr;
  }
  if (fl_value_get_type(values) != FL_VALUE_TYPE_LIST ||
      fl_value_get_type(fl_value_get_list_value(values, 0)) !=
          FL_VALUE_TYPE_STRING ||
      fl_value_get_type(fl_value_get_list_value(values, 1)) !=
          FL_VALUE_TYPE_STRING ||
      fl_value_get_type(fl_value_get_list_value(values, 2)) !=
          FL_VALUE_TYPE_INT ||
      fl_value_get_type(fl_value_get_list_value(values, 3)) !=
          FL_VALUE_TYPE_MAP) {
    g_set_error(error, FL_MESSAGE_CODEC_ERROR, FL_MESSAGE_CODEC_ERROR_FAILED,
                "Invalid data received for MessageData");
    return nullptr;
  }

  return fl_value_new_custom_object_take(
      128, G_OBJECT(my_message_data_new(
               fl_value_get_string(fl_value_get_list_value(values, 0)),
               fl_value_get_string(fl_value_get_list_value(values, 1)),
               static_cast<MyCode>(
                   fl_value_get_int(fl_value_get_list_value(values, 2))),
               fl_value_get_list_value(values, 3))));
}

G_DECLARE_FINAL_TYPE(MyExampleHostApiCodec, my_example_host_api_codec, MY,
                     EXAMPLE_HOST_API_CODEC, FlStandardMessageCodec)

struct _MyExampleHostApiCodec {
  FlStandardMessageCodec parent_instance;
};

G_DEFINE_TYPE(MyExampleHostApiCodec, my_example_host_api_codec,
              fl_standard_message_codec_get_type())

static gboolean my_example_host_api_write_value(FlStandardMessageCodec* codec,
                                                GByteArray* buffer,
                                                FlValue* value,
                                                GError** error) {
  if (fl_value_get_type(value) == FL_VALUE_TYPE_CUSTOM) {
    switch (fl_value_get_custom_type(value)) {
      case 128:
        return my_message_data_write_value(
            codec, buffer,
            MY_MESSAGE_DATA(fl_value_get_custom_value_object(value)), error);
    }
  }

  return FL_STANDARD_MESSAGE_CODEC_CLASS(my_example_host_api_codec_parent_class)
      ->write_value(codec, buffer, value, error);
}

static FlValue* my_example_host_api_read_value_of_type(
    FlStandardMessageCodec* codec, GBytes* buffer, size_t* offset, int type,
    GError** error) {
  switch (type) {
    case 128:
      return my_message_data_read_value(codec, buffer, offset, error);
    default:
      return FL_STANDARD_MESSAGE_CODEC_CLASS(
                 my_example_host_api_codec_parent_class)
          ->read_value_of_type(codec, buffer, offset, type, error);
  }
}

static void my_example_host_api_codec_init(MyExampleHostApiCodec* self) {}

static void my_example_host_api_codec_class_init(
    MyExampleHostApiCodecClass* klass) {
  FL_STANDARD_MESSAGE_CODEC_CLASS(klass)->write_value =
      my_example_host_api_write_value;
  FL_STANDARD_MESSAGE_CODEC_CLASS(klass)->read_value_of_type =
      my_example_host_api_read_value_of_type;
}

static MyExampleHostApiCodec* my_example_host_api_codec_new() {
  MyExampleHostApiCodec* self = MY_EXAMPLE_HOST_API_CODEC(
      g_object_new(my_example_host_api_codec_get_type(), nullptr));
  return self;
}

struct _MyExampleHostApiGetHostLanguageResponse {
  GObject parent_instance;

  FlValue* value;
};

G_DEFINE_TYPE(MyExampleHostApiGetHostLanguageResponse,
              my_example_host_api_get_host_language_response, G_TYPE_OBJECT)

static void my_example_host_api_get_host_language_response_dispose(
    GObject* object) {
  MyExampleHostApiGetHostLanguageResponse* self =
      MY_EXAMPLE_HOST_API_GET_HOST_LANGUAGE_RESPONSE(object);
  g_clear_pointer(&self->value, fl_value_unref);
  G_OBJECT_CLASS(my_example_host_api_get_host_language_response_parent_class)
      ->dispose(object);
}

static void my_example_host_api_get_host_language_response_init(
    MyExampleHostApiGetHostLanguageResponse* self) {}

static void my_example_host_api_get_host_language_response_class_init(
    MyExampleHostApiGetHostLanguageResponseClass* klass) {
  G_OBJECT_CLASS(klass)->dispose =
      my_example_host_api_get_host_language_response_dispose;
}

MyExampleHostApiGetHostLanguageResponse*
my_example_host_api_get_host_language_response_new(const gchar* return_value) {
  MyExampleHostApiGetHostLanguageResponse* self =
      MY_EXAMPLE_HOST_API_GET_HOST_LANGUAGE_RESPONSE(g_object_new(
          my_example_host_api_get_host_language_response_get_type(), nullptr));
  self->value = fl_value_new_list();
  fl_value_append_take(self->value, fl_value_new_string(return_value));
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
  g_clear_pointer(&self->value, fl_value_unref);
  G_OBJECT_CLASS(my_example_host_api_add_response_parent_class)
      ->dispose(object);
}

static void my_example_host_api_add_response_init(
    MyExampleHostApiAddResponse* self) {}

static void my_example_host_api_add_response_class_init(
    MyExampleHostApiAddResponseClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = my_example_host_api_add_response_dispose;
}

MyExampleHostApiAddResponse* my_example_host_api_add_response_new(
    int64_t return_value) {
  MyExampleHostApiAddResponse* self = MY_EXAMPLE_HOST_API_ADD_RESPONSE(
      g_object_new(my_example_host_api_add_response_get_type(), nullptr));
  self->value = fl_value_new_list();
  fl_value_append_take(self->value, fl_value_new_int(return_value));
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

G_DECLARE_FINAL_TYPE(MyExampleHostApiSendMessageResponse,
                     my_example_host_api_send_message_response, MY,
                     EXAMPLE_HOST_API_SEND_MESSAGE_RESPONSE, GObject)

struct _MyExampleHostApiSendMessageResponse {
  GObject parent_instance;

  FlValue* value;
};

G_DEFINE_TYPE(MyExampleHostApiSendMessageResponse,
              my_example_host_api_send_message_response, G_TYPE_OBJECT)

static void my_example_host_api_send_message_response_dispose(GObject* object) {
  MyExampleHostApiSendMessageResponse* self =
      MY_EXAMPLE_HOST_API_SEND_MESSAGE_RESPONSE(object);
  g_clear_pointer(&self->value, fl_value_unref);
  G_OBJECT_CLASS(my_example_host_api_send_message_response_parent_class)
      ->dispose(object);
}

static void my_example_host_api_send_message_response_init(
    MyExampleHostApiSendMessageResponse* self) {}

static void my_example_host_api_send_message_response_class_init(
    MyExampleHostApiSendMessageResponseClass* klass) {
  G_OBJECT_CLASS(klass)->dispose =
      my_example_host_api_send_message_response_dispose;
}

static MyExampleHostApiSendMessageResponse*
my_example_host_api_send_message_response_new(gboolean return_value) {
  MyExampleHostApiSendMessageResponse* self =
      MY_EXAMPLE_HOST_API_SEND_MESSAGE_RESPONSE(g_object_new(
          my_example_host_api_send_message_response_get_type(), nullptr));
  self->value = fl_value_new_list();
  fl_value_append_take(self->value, fl_value_new_bool(return_value));
  return self;
}

static MyExampleHostApiSendMessageResponse*
my_example_host_api_send_message_response_new_error(const gchar* code,
                                                    const gchar* message,
                                                    FlValue* details) {
  MyExampleHostApiSendMessageResponse* self =
      MY_EXAMPLE_HOST_API_SEND_MESSAGE_RESPONSE(g_object_new(
          my_example_host_api_send_message_response_get_type(), nullptr));
  self->value = fl_value_new_list();
  fl_value_append_take(self->value, fl_value_new_string(code));
  fl_value_append_take(self->value, fl_value_new_string(message));
  fl_value_append(self->value, details);
  return self;
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

  if (self->vtable == nullptr || self->vtable->get_host_language == nullptr) {
    return;
  }

  if (fl_value_get_type(message) != FL_VALUE_TYPE_NULL) {
    return;
  }

  g_autoptr(MyExampleHostApiGetHostLanguageResponse) response =
      self->vtable->get_host_language(self, self->user_data);
  if (response == nullptr) {
    g_warning("No response returned to ExampleHostApi.getHostLanguage");
    return;
  }

  g_autoptr(GError) error = NULL;
  if (!fl_basic_message_channel_respond(channel, response_handle,
                                        response->value, &error)) {
    g_warning("Failed to send response to ExampleHostApi.getHostLanguage: %s",
              error->message);
  }
}

static void add_cb(FlBasicMessageChannel* channel, FlValue* message,
                   FlBasicMessageChannelResponseHandle* response_handle,
                   gpointer user_data) {
  MyExampleHostApi* self = MY_EXAMPLE_HOST_API(user_data);

  if (self->vtable == nullptr || self->vtable->add == nullptr) {
    return;
  }

  if (fl_value_get_type(message) != FL_VALUE_TYPE_LIST ||
      fl_value_get_length(message) != 2 ||
      fl_value_get_type(fl_value_get_list_value(message, 0)) !=
          FL_VALUE_TYPE_INT ||
      fl_value_get_type(fl_value_get_list_value(message, 1)) !=
          FL_VALUE_TYPE_INT) {
    return;
  }

  g_autoptr(MyExampleHostApiAddResponse) response = self->vtable->add(
      self, fl_value_get_int(fl_value_get_list_value(message, 0)),
      fl_value_get_int(fl_value_get_list_value(message, 1)), self->user_data);
  if (response == nullptr) {
    g_warning("No response returned to ExampleHostApi.add");
  }

  g_autoptr(GError) error = NULL;
  if (!fl_basic_message_channel_respond(channel, response_handle,
                                        response->value, &error)) {
    g_warning("Failed to send response to ExampleHostApi.add: %s",
              error->message);
  }
}

static void send_message_cb(
    FlBasicMessageChannel* channel, FlValue* message,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  MyExampleHostApi* self = MY_EXAMPLE_HOST_API(user_data);

  if (self->vtable == nullptr || self->vtable->send_message == nullptr) {
    return;
  }

  if (fl_value_get_type(message) != FL_VALUE_TYPE_LIST ||
      fl_value_get_length(message) != 1 ||
      fl_value_get_type(fl_value_get_list_value(message, 0)) !=
          FL_VALUE_TYPE_CUSTOM) {
    return;
  }

  self->vtable->send_message(self,
                             MY_MESSAGE_DATA(fl_value_get_custom_value_object(
                                 fl_value_get_list_value(message, 0))),
                             response_handle, self->user_data);
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
  G_OBJECT_CLASS(klass)->dispose = my_example_host_api_dispose;
}

MyExampleHostApi* my_example_host_api_new(FlBinaryMessenger* messenger,
                                          const MyExampleHostApiVTable* vtable,
                                          gpointer user_data,
                                          GDestroyNotify user_data_free_func) {
  MyExampleHostApi* self = MY_EXAMPLE_HOST_API(
      g_object_new(my_example_host_api_get_type(), nullptr));
  self->messenger = g_object_ref(messenger);
  self->vtable = vtable;
  self->user_data = user_data;
  self->user_data_free_func = user_data_free_func;

  g_autoptr(MyExampleHostApiCodec) codec = my_example_host_api_codec_new();
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

void my_example_host_api_respond_send_message(
    MyExampleHostApi* self,
    FlBasicMessageChannelResponseHandle* response_handle,
    gboolean return_value) {
  g_autoptr(MyExampleHostApiSendMessageResponse) response =
      my_example_host_api_send_message_response_new(return_value);
  g_autoptr(GError) error = nullptr;
  if (!fl_basic_message_channel_respond(self->send_message_channel,
                                        response_handle, response->value,
                                        &error)) {
    g_warning("Failed to send response to ExampleHostApi.sendMessage: %s",
              error->message);
  }
}

void my_example_host_api_respond_error_send_message(
    MyExampleHostApi* self,
    FlBasicMessageChannelResponseHandle* response_handle, const gchar* code,
    const gchar* message, FlValue* details) {
  g_autoptr(MyExampleHostApiSendMessageResponse) response =
      my_example_host_api_send_message_response_new_error(code, message,
                                                          details);
  g_autoptr(GError) error = nullptr;
  if (!fl_basic_message_channel_respond(self->send_message_channel,
                                        response_handle, response->value,
                                        &error)) {
    g_warning("Failed to send response to ExampleHostApi.sendMessage: %s",
              error->message);
  }
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
  G_OBJECT_CLASS(klass)->dispose = my_message_flutter_api_dispose;
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
    MyMessageFlutterApi* object, GAsyncResult* result, gchar** return_value,
    GError** error) {
  return TRUE;
}
