# Introduction #

A series of independent small requests can be batched together into a single request. This may be more efficient than sending individual requests, depending on the platform you are working on. You should consider how your application is used and the size of requests when using batching.


# Details #

Create batch requests by instantiating a `Google::APIClient::BatchRequest` object
and then adding each request you want to execute. You may pass
in a block, which will be used as a callback, with each request that will be called.

```
client = Google::APIClient.new
zoo = client.discovered_api('zoo', 'v1')

batch = Google::APIClient::BatchRequest.new do 

get_elephant = {
  :api_method => zoo.animals.get,
  :parameters => {
    'name' => 'Elephant'
  }
}

list_animals = {
  :api_method => zoo.animals.list,
  :parameters => {}
}

batch = Google::APIClient::BatchRequest.new

batch.add(get_elephant) do |result|
  # Do something with elephant
end

batch.add(list_animals) do |result|
  # Do something with animal list
end

client.execute(batch)
```

You can also supply a single callback that gets called for
each response.

```
client = Google::APIClient.new
zoo = client.discovered_api('zoo', 'v1')

batch = Google::APIClient::BatchRequest.new do |result|
end

insert_lion = {
  :api_method => zoo.animals.insert,
  :parameters => {
    'name' => 'Lion'
  }
}

insert_tiger = {
  :api_method => zoo.animals.insert,
  :parameters => {
    'name' => 'Tiger'
  }
}

insert_bear = {
  :api_method => zoo.animals.insert,
  :parameters => {
    'name' => 'Bear'
  }
}

batch = Google::APIClient::BatchRequest.new do |result|
  # Do something with the animal result.
end

batch.add(insert_lion).add(insert_tiger).add(insert_bear)
client.execute(batch)
```

The `add()` method also allows you to supply the id for
each request, but if you don't supply one then the library
will create one for you. Make sure that if you supply ids that
they are all unique, otherwise `add()` will raise an exception.

The callback to `new()` will only get called if there is no specific callback for `add()`.