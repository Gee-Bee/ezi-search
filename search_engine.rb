require 'stemmify'
require 'matrix'

class SearchEngine

  def initialize keywords, documents
    @terms = parse_keywords keywords
    @documents = parse_documents documents
    set_idf
  end

  def search query
    query_tf_idf = tf_idf(tf(bag_of_words(word_count(query || ''))))
    update_sim_td_idf_for query_tf_idf
    @documents.
      select {|doc| doc[:sim_tf_idf] > 0}.
      sort {|doc1, doc2| doc2[:sim_tf_idf] <=> doc1[:sim_tf_idf]}
  end

  def word_count string
    string.
      downcase.gsub(/\W+/, ' ').
      split(' ').map(&:stem).
      each_with_object(Hash.new(0)) { |word, h| h[word] += 1 }
  end

  def bag_of_words wc
    Vector.elements @terms.map {|term| wc[term]}
  end

  def tf bow
    bow.r == 0 && bow || bow.normalize
  end

  def tf_idf tf
    Vector.elements tf.zip(@idf).map{ |i, j| i * j }
  end

  def sim_tf_idf v1, v2
    v1.dot(v2) / (v1.r * v2.r)
  end

private

  def parse_keywords keywords
    keywords.split(/\r?\n/).map(&:stem).sort.uniq
  end

  def parse_documents documents
    documents.force_encoding('windows-1252').encode('UTF-8').split(/\r?\n\r?\n/).map do |content|
      wc = word_count(content)
      bow = bag_of_words(wc)
      {
        content: content,
        word_count: wc,
        bag_of_words: bow,
        tf: tf(bow),
      }
    end
  end

  def set_idf
    @idf = @terms.map {|term| Math.log(@documents.length.to_f / @documents.select {|doc| doc[:word_count].has_key?(term)}.length)}
    @documents.each {|doc| doc[:tf_idf] = tf_idf(doc[:tf])}
  end

  def update_sim_td_idf_for tf_idf
    @documents.each {|doc| doc[:sim_tf_idf] = sim_tf_idf(doc[:tf_idf], tf_idf)}
  end
end
