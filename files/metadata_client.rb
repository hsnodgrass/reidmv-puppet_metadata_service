require 'cassandra'
require 'mongo'

# DB client factory
class PuppetMetadataClient
  def self.for(db_type:, hosts:, **kwargs)
    kwargs.delete_if { |key, value| value.empty? }
    case db_type
    when 'cassandra'
      CassandraMetadataClient.new(hosts: hosts, kwargs: kwargs)
    when 'mongodb'
      MongoMetadataClient.new(hosts: hosts, kwargs: kwargs)
    else
      raise "Database #{database} is not supported!"
    end
  end
end
  
# Abstract class that MetadataClient classes should inherit from
# Assists in keeping the clients uniform
class MetadataClientAbstract
  def initialize(hosts:, kwargs:)
    raise NotImplementedError, "#{self.class} has not implemented method of '#{__method__}'"
  end

  def with_session
    raise NotImplementedError, "#{self.class} has not implemented method of '#{__method__}'"
  end

  def get_nodedata(certname:)
    raise NotImplementedError, "#{self.class} has not implemented method of '#{__method__}'"
  end
end
  
  
class CassandraMetadataClient < MetadataClientAbstract
  def initialize(hosts:, kwargs:)
    @cluster = Cassandra.cluster(hosts: hosts)
    if kwargs.has_key?(:keyspace)
      @keyspace = kwargs[:keyspace]
    else
      @keyspace = 'puppet'
    end
  end

  # No need to treat this as a context manager because cassandra-driver sessions close themselves
  def with_session
    session = @cluster.connect(@keyspace) # create session, optionally scoped to a keyspace, to execute queries
    return session unless block_given?
    yield session
  end

  def get_nodedata(certname:)
    self.with_session do | session |
      statement = session.prepare('SELECT json classes,environment,release FROM nodedata WHERE certname=?').bind([certname])
      result = session.execute(statement)
    end
    if result.first.nil?
      return {}
    else
      return {'nodedata' => JSON.parse(result.first['[json]']) }
    end
  end
end
  
  
class MongoMetadataClient < MetadataClientAbstract
  def initialize(hosts:, kwargs:)
    @client = Mongo::Client.new(hosts, kwargs)
  end

  # Mongo requires that you explicitly close sessions.
  # This impl can be used as a context manager like so:
  # client.new_session do | s |
  #   s.with_transaction do
  #     ...
  #   end
  # end
  def with_session(*args)
    session = @client.start_session
    return session unless block_given?
    yield session
  ensure
    session.end_session if block_given?
  end

  def get_nodedata(certname:)
    self.with_session do | session |
      session.with_transaction do
        collection = @client[:nodedata]
        result = collection.find( {:certname => certname }, session: session).limit(1)
      end
    end
    return { 'nodedata' => JSON.parse(result) }
  end
end